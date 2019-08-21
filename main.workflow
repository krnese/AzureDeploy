workflow "New workflow" {
  on = "push"
  resolves = ["Deploy to Azure"]
}


action "Deploy to Azure" {
  uses = "./.github/AzureDeploy"
  secrets = ["USER", "PWD"]
  env = {
    SERVICE_PRINCIPAL = "http://GitHubActionsSP",
    TENANT_ID="YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY",
    APPID="YourAppIdX100"
  }
}