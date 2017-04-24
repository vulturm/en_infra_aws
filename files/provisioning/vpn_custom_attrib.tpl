{
  "openvpn": {
    "tar_path": "/home/${client_prefix}/keys",
    "script_security": 2,
    "push_routes": [
      "${push_routes_array}"
    ],
    "gateway": "${gateway_address}",
    "config": {
      "proto": "${vpn_proto}",
      "cipher": "AES-256-CBC",
      "port": ${vpn_port}
    },
    "client_prefix": "${client_prefix}",
    "signing_ca_cert": "/etc/openvpn/keys/${client_prefix}.crt",
    "signing_ca_key": "/etc/openvpn/keys/${client_prefix}.key",
    "key": {
      "country": "RO",
      "province": "CJ",
      "city": "Cluj Napoca",
      "org": "Endava",
      "email": "ROCLDDevOps@endava.com"
    }
  },
  "run_list": [
    "recipe[en_deploy_openvpn]"
  ]
}
