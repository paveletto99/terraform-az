# Terraform Azure

🧑‍💻 WIP

## Tools

<https://www.runatlantis.io/>

## Azure Auth 🔑

login and create service principal app

```shell
az login

az account set --subscription "👾"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/👾"
```

SP creation output:

```shell
{
  "appId": "",
  "displayName": "",
  "password": "",
  "tenant": ""
}
```

create a `.env` file map the values on it:

```bash
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"
```
