output "api_gateway_endpoint" {
  description = "Base URL for API Gateway stage."
  value       = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}/"
}

output "dynamodb_vpc_endpoint_id" {
  value = aws_vpc_endpoint.dynamodb.id
}