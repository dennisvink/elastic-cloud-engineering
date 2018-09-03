# Elastic Cloud Engineering Demo Repository

This is the demo repository for my Elastic Cloud Engineeering talk at the AWS Meetup in Amsterdam.
The stack sets up a CI/CD environment consisting of:

- A custom resource that creates a Github Webhook (You need to create an access token and add it to .env.private)
- Step Functions and relevant Lambda functions to report on build status
- An API Gateway

When creating a PR, the webhook triggers CodeBuild. The buildspec.yml from the repository is used. The build
status is reported back to Github.

## Installing dependencies

`bundle install`

# Build cloudformation template

`rake`

