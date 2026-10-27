AddPackage --foreign chatgpt-desktop
AddPackage tpm2-tss

cat >"$(CreateFile /etc/udev/rules.d/99-chatgpt-tpm-access.rules)" <<EOF
SUBSYSTEM=="tpmrm", KERNEL=="tpmrm0", RUN+="/usr/bin/setfacl -m u:${cfg_user}:rw /dev/%k"
EOF

for profile in P_ECCP384SHA384 P_RSA3072SHA384; do
    tpm_profile=$(GetPackageOriginalFile tpm2-tss "/etc/tpm2-tss/fapi-profiles/$profile.json")
    tpm_json=$(jq '
        walk(if type == "string" then
            if test("^(aes|cfb|ecc|ecdsa|oaep|rsa|rsapss|sha1|sha256|sha384)$") then "TPM2_ALG_" + ascii_upcase
            elif . == "nist_p384" then "TPM2_ECC_NIST_P384"
            elif . == "policysecret" then "POLICYSECRET"
            else . end
        else . end)
        | .srk_template |= sub(",noda,"; ",")
        | .srk_persistent = (if .type == "TPM2_ALG_RSA" then 1 else 0 end)
    ' "$tpm_profile")
    printf '%s\n' "$tpm_json" >"$tpm_profile"
done
