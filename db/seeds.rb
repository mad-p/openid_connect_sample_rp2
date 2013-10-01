Provider.create!(
  name:                     'Microsoft',
  issuer:                   'https://sts.windows.net/b4ea3de6-839e-4ad1-ae78-c78e5c0cdc06/',
  identifier:               '7db0f079-8e21-4914-9a9b-0896c80f4816',
  secret:                   'Mp8EAXSOlVOeQaAlAADwtboofkUd8gycok8TvTGmKHM=',
  scopes_supported:         'openid',
  response_types_supported: 'id_token',
  authorization_endpoint:   'https://login.windows.net/b4ea3de6-839e-4ad1-ae78-c78e5c0cdc06/oauth2/authorize',
  token_endpoint:           'https://login.windows.net/b4ea3de6-839e-4ad1-ae78-c78e5c0cdc06/oauth2/token',
  userinfo_endpoint:        'https://login.windows.net/b4ea3de6-839e-4ad1-ae78-c78e5c0cdc06/oauth2/userinfo',
  jwks_uri:                 'https://login.windows.net/common/discovery/keys'
)