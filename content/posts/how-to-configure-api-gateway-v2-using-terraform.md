+++
date = 2020-11-11
title = "How to configure API Gateway v2 using Terraform"
+++

Here's how you wire up an AWS lambda into an HTTP API using Terraform
and AWS's API Gateway v2 resources.

<!-- more -->

When you `terraform apply` this, it'll spit out an API URL. You can `GET
/` against that API URL to run your lambda:

```terraform
resource "aws_iam_role" "plants" {
  name = "iam_plant_api"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      }
    }
  ]
}
EOF
}

# This presumes you have a zip file get_water_level.zip
# which contains a get_water_level.js file which exports
# a `handler` function
resource "aws_lambda_function" "get_water_level" {
  filename = "get_water_level.zip"
  function_name = "get_water_level"
  publish = true
  role = aws_iam_role.plants.arn
  handler = "get_water_level.handler"
  source_code_hash = filebase64sha256("get_water_level.zip")
  runtime = "nodejs12.x"
}

resource "aws_apigatewayv2_api" "plants" {
  name          = "http-plants"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "plants_prod" {
  api_id = aws_apigatewayv2_api.plants.id
  name = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "get_water_level" {
  api_id = aws_apigatewayv2_api.plants.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.get_water_level.invoke_arn
}

resource "aws_apigatewayv2_route" "get_water_level" {
  api_id = aws_apigatewayv2_api.plants.id
  route_key = "GET /"
  target = "integrations/${aws_apigatewayv2_integration.get_water_level.id}"
}

resource "aws_lambda_permission" "get_water_level" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_water_level.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_stage.plants_prod.execution_arn}/*"
}

output "api_url" {
  value = aws_apigatewayv2_stage.plants_prod.invoke_url
}
```

### Notes

1. **Anyone with the URL will be able to invoke your lambda.** If you want
   access control or rate limiting, you'll need to add that.

2. Without the `aws_lambda_permission`, your API Gateway won't have permission
   to invoke the lambda and it'll 500.

3. The `aws_apigatewayv2_stage` is a staging environment (e.g. development,
   production, test). You must have at least one stage, or else calls to your
   API will fail with "Not Found".

4. The `aws_lambda_permission` lets **any** route on your API's `$default`
   stage invoke the lambda. If you want to restrict it to a particular route,
   you can make the `source_arn` more specific.

### Resources

- [The Official AWS Documentation][official_docs] - Thorough, verbose, not Terraform-specific.
- [How to use the `aws_apigatewayv2_api` to add an HTTP API to a Lambda function][advancedweb] - Omits the fact that you need a `stage`.
- [HTTP APIs with Simple Lambda Functions][barneyparker] - Omits the `aws_lambda_permission`, but shows you how to add logging.

[official_docs]: https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html
[advancedweb]: https://advancedweb.hu/how-to-use-the-aws-apigatewayv2-api-to-add-an-http-api-to-a-lambda-function/
[barneyparker]: https://barneyparker.com/posts/http-apis-with-simple-lambda-functions/
