defmodule XHTTP.Transport.SSL do
  require Logger

  @behaviour XHTTP.Transport

  # TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA
  # {:ecdhe_ecdsa, :aes_128_cbc, :sha}

  @blacklisted_ciphers [
    'TLS_NULL_WITH_NULL_NULL',
    'TLS_RSA_WITH_NULL_MD5',
    'TLS_RSA_WITH_NULL_SHA',
    'TLS_RSA_EXPORT_WITH_RC4_40_MD5',
    'TLS_RSA_WITH_RC4_128_MD5',
    'TLS_RSA_WITH_RC4_128_SHA',
    'TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5',
    'TLS_RSA_WITH_IDEA_CBC_SHA',
    'TLS_RSA_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_RSA_WITH_DES_CBC_SHA',
    'TLS_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_DH_DSS_WITH_DES_CBC_SHA',
    'TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA',
    'TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_DH_RSA_WITH_DES_CBC_SHA',
    'TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_DHE_DSS_WITH_DES_CBC_SHA',
    'TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA',
    'TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_DHE_RSA_WITH_DES_CBC_SHA',
    'TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_DH_anon_EXPORT_WITH_RC4_40_MD5',
    'TLS_DH_anon_WITH_RC4_128_MD5',
    'TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA',
    'TLS_DH_anon_WITH_DES_CBC_SHA',
    'TLS_DH_anon_WITH_3DES_EDE_CBC_SHA',
    'TLS_KRB5_WITH_DES_CBC_SHA',
    'TLS_KRB5_WITH_3DES_EDE_CBC_SHA',
    'TLS_KRB5_WITH_RC4_128_SHA',
    'TLS_KRB5_WITH_IDEA_CBC_SHA',
    'TLS_KRB5_WITH_DES_CBC_MD5',
    'TLS_KRB5_WITH_3DES_EDE_CBC_MD5',
    'TLS_KRB5_WITH_RC4_128_MD5',
    'TLS_KRB5_WITH_IDEA_CBC_MD5',
    'TLS_KRB5_EXPORT_WITH_DES_CBC_40_SHA',
    'TLS_KRB5_EXPORT_WITH_RC2_CBC_40_SHA',
    'TLS_KRB5_EXPORT_WITH_RC4_40_SHA',
    'TLS_KRB5_EXPORT_WITH_DES_CBC_40_MD5',
    'TLS_KRB5_EXPORT_WITH_RC2_CBC_40_MD5',
    'TLS_KRB5_EXPORT_WITH_RC4_40_MD5',
    'TLS_PSK_WITH_NULL_SHA',
    'TLS_DHE_PSK_WITH_NULL_SHA',
    'TLS_RSA_PSK_WITH_NULL_SHA',
    'TLS_RSA_WITH_AES_128_CBC_SHA',
    'TLS_DH_DSS_WITH_AES_128_CBC_SHA',
    'TLS_DH_RSA_WITH_AES_128_CBC_SHA',
    'TLS_DHE_DSS_WITH_AES_128_CBC_SHA',
    'TLS_DHE_RSA_WITH_AES_128_CBC_SHA',
    'TLS_DH_anon_WITH_AES_128_CBC_SHA',
    'TLS_RSA_WITH_AES_256_CBC_SHA',
    'TLS_DH_DSS_WITH_AES_256_CBC_SHA',
    'TLS_DH_RSA_WITH_AES_256_CBC_SHA',
    'TLS_DHE_DSS_WITH_AES_256_CBC_SHA',
    'TLS_DHE_RSA_WITH_AES_256_CBC_SHA',
    'TLS_DH_anon_WITH_AES_256_CBC_SHA',
    'TLS_RSA_WITH_NULL_SHA256',
    'TLS_RSA_WITH_AES_128_CBC_SHA256',
    'TLS_RSA_WITH_AES_256_CBC_SHA256',
    'TLS_DH_DSS_WITH_AES_128_CBC_SHA256',
    'TLS_DH_RSA_WITH_AES_128_CBC_SHA256',
    'TLS_DHE_DSS_WITH_AES_128_CBC_SHA256',
    'TLS_RSA_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA',
    'TLS_DHE_RSA_WITH_AES_128_CBC_SHA256',
    'TLS_DH_DSS_WITH_AES_256_CBC_SHA256',
    'TLS_DH_RSA_WITH_AES_256_CBC_SHA256',
    'TLS_DHE_DSS_WITH_AES_256_CBC_SHA256',
    'TLS_DHE_RSA_WITH_AES_256_CBC_SHA256',
    'TLS_DH_anon_WITH_AES_128_CBC_SHA256',
    'TLS_DH_anon_WITH_AES_256_CBC_SHA256',
    'TLS_RSA_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA',
    'TLS_PSK_WITH_RC4_128_SHA',
    'TLS_PSK_WITH_3DES_EDE_CBC_SHA',
    'TLS_PSK_WITH_AES_128_CBC_SHA',
    'TLS_PSK_WITH_AES_256_CBC_SHA',
    'TLS_DHE_PSK_WITH_RC4_128_SHA',
    'TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA',
    'TLS_DHE_PSK_WITH_AES_128_CBC_SHA',
    'TLS_DHE_PSK_WITH_AES_256_CBC_SHA',
    'TLS_RSA_PSK_WITH_RC4_128_SHA',
    'TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA',
    'TLS_RSA_PSK_WITH_AES_128_CBC_SHA',
    'TLS_RSA_PSK_WITH_AES_256_CBC_SHA',
    'TLS_RSA_WITH_SEED_CBC_SHA',
    'TLS_DH_DSS_WITH_SEED_CBC_SHA',
    'TLS_DH_RSA_WITH_SEED_CBC_SHA',
    'TLS_DHE_DSS_WITH_SEED_CBC_SHA',
    'TLS_DHE_RSA_WITH_SEED_CBC_SHA',
    'TLS_DH_anon_WITH_SEED_CBC_SHA',
    'TLS_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_DH_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_DH_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_DH_DSS_WITH_AES_128_GCM_SHA256',
    'TLS_DH_DSS_WITH_AES_256_GCM_SHA384',
    'TLS_DH_anon_WITH_AES_128_GCM_SHA256',
    'TLS_DH_anon_WITH_AES_256_GCM_SHA384',
    'TLS_PSK_WITH_AES_128_GCM_SHA256',
    'TLS_PSK_WITH_AES_256_GCM_SHA384',
    'TLS_RSA_PSK_WITH_AES_128_GCM_SHA256',
    'TLS_RSA_PSK_WITH_AES_256_GCM_SHA384',
    'TLS_PSK_WITH_AES_128_CBC_SHA256',
    'TLS_PSK_WITH_AES_256_CBC_SHA384',
    'TLS_PSK_WITH_NULL_SHA256',
    'TLS_PSK_WITH_NULL_SHA384',
    'TLS_DHE_PSK_WITH_AES_128_CBC_SHA256',
    'TLS_DHE_PSK_WITH_AES_256_CBC_SHA384',
    'TLS_DHE_PSK_WITH_NULL_SHA256',
    'TLS_DHE_PSK_WITH_NULL_SHA384',
    'TLS_RSA_PSK_WITH_AES_128_CBC_SHA256',
    'TLS_RSA_PSK_WITH_AES_256_CBC_SHA384',
    'TLS_RSA_PSK_WITH_NULL_SHA256',
    'TLS_RSA_PSK_WITH_NULL_SHA384',
    'TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256',
    'TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA256',
    'TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA256',
    'TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA256',
    'TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256',
    'TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA256',
    # 'TLS_EMPTY_RENEGOTIATION_INFO_SCSV',
    'TLS_ECDH_ECDSA_WITH_NULL_SHA',
    'TLS_ECDH_ECDSA_WITH_RC4_128_SHA',
    'TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA',
    'TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA',
    'TLS_ECDHE_ECDSA_WITH_NULL_SHA',
    'TLS_ECDHE_ECDSA_WITH_RC4_128_SHA',
    'TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA',
    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA',
    'TLS_ECDH_RSA_WITH_NULL_SHA',
    'TLS_ECDH_RSA_WITH_RC4_128_SHA',
    'TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDH_RSA_WITH_AES_128_CBC_SHA',
    'TLS_ECDH_RSA_WITH_AES_256_CBC_SHA',
    'TLS_ECDHE_RSA_WITH_NULL_SHA',
    'TLS_ECDHE_RSA_WITH_RC4_128_SHA',
    'TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA',
    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
    'TLS_ECDH_anon_WITH_NULL_SHA',
    'TLS_ECDH_anon_WITH_RC4_128_SHA',
    'TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDH_anon_WITH_AES_128_CBC_SHA',
    'TLS_ECDH_anon_WITH_AES_256_CBC_SHA',
    'TLS_SRP_SHA_WITH_3DES_EDE_CBC_SHA',
    'TLS_SRP_SHA_RSA_WITH_3DES_EDE_CBC_SHA',
    'TLS_SRP_SHA_DSS_WITH_3DES_EDE_CBC_SHA',
    'TLS_SRP_SHA_WITH_AES_128_CBC_SHA',
    'TLS_SRP_SHA_RSA_WITH_AES_128_CBC_SHA',
    'TLS_SRP_SHA_DSS_WITH_AES_128_CBC_SHA',
    'TLS_SRP_SHA_WITH_AES_256_CBC_SHA',
    'TLS_SRP_SHA_RSA_WITH_AES_256_CBC_SHA',
    'TLS_SRP_SHA_DSS_WITH_AES_256_CBC_SHA',
    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256',
    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384',
    'TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256',
    'TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384',
    'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
    'TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256',
    'TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384',
    'TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256',
    'TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384',
    'TLS_ECDHE_PSK_WITH_RC4_128_SHA',
    'TLS_ECDHE_PSK_WITH_3DES_EDE_CBC_SHA',
    'TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA',
    'TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA',
    'TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA256',
    'TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA384',
    'TLS_ECDHE_PSK_WITH_NULL_SHA',
    'TLS_ECDHE_PSK_WITH_NULL_SHA256',
    'TLS_ECDHE_PSK_WITH_NULL_SHA384',
    'TLS_RSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_RSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_DH_DSS_WITH_ARIA_128_CBC_SHA256',
    'TLS_DH_DSS_WITH_ARIA_256_CBC_SHA384',
    'TLS_DH_RSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_DH_RSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_DHE_DSS_WITH_ARIA_128_CBC_SHA256',
    'TLS_DHE_DSS_WITH_ARIA_256_CBC_SHA384',
    'TLS_DHE_RSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_DHE_RSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_DH_anon_WITH_ARIA_128_CBC_SHA256',
    'TLS_DH_anon_WITH_ARIA_256_CBC_SHA384',
    'TLS_ECDHE_ECDSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_ECDHE_ECDSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_ECDH_ECDSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_ECDH_ECDSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_ECDHE_RSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_ECDHE_RSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_ECDH_RSA_WITH_ARIA_128_CBC_SHA256',
    'TLS_ECDH_RSA_WITH_ARIA_256_CBC_SHA384',
    'TLS_RSA_WITH_ARIA_128_GCM_SHA256',
    'TLS_RSA_WITH_ARIA_256_GCM_SHA384',
    'TLS_DH_RSA_WITH_ARIA_128_GCM_SHA256',
    'TLS_DH_RSA_WITH_ARIA_256_GCM_SHA384',
    'TLS_DH_DSS_WITH_ARIA_128_GCM_SHA256',
    'TLS_DH_DSS_WITH_ARIA_256_GCM_SHA384',
    'TLS_DH_anon_WITH_ARIA_128_GCM_SHA256',
    'TLS_DH_anon_WITH_ARIA_256_GCM_SHA384',
    'TLS_ECDH_ECDSA_WITH_ARIA_128_GCM_SHA256',
    'TLS_ECDH_ECDSA_WITH_ARIA_256_GCM_SHA384',
    'TLS_ECDH_RSA_WITH_ARIA_128_GCM_SHA256',
    'TLS_ECDH_RSA_WITH_ARIA_256_GCM_SHA384',
    'TLS_PSK_WITH_ARIA_128_CBC_SHA256',
    'TLS_PSK_WITH_ARIA_256_CBC_SHA384',
    'TLS_DHE_PSK_WITH_ARIA_128_CBC_SHA256',
    'TLS_DHE_PSK_WITH_ARIA_256_CBC_SHA384',
    'TLS_RSA_PSK_WITH_ARIA_128_CBC_SHA256',
    'TLS_RSA_PSK_WITH_ARIA_256_CBC_SHA384',
    'TLS_PSK_WITH_ARIA_128_GCM_SHA256',
    'TLS_PSK_WITH_ARIA_256_GCM_SHA384',
    'TLS_RSA_PSK_WITH_ARIA_128_GCM_SHA256',
    'TLS_RSA_PSK_WITH_ARIA_256_GCM_SHA384',
    'TLS_ECDHE_PSK_WITH_ARIA_128_CBC_SHA256',
    'TLS_ECDHE_PSK_WITH_ARIA_256_CBC_SHA384',
    'TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_ECDH_ECDSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_ECDH_ECDSA_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_ECDH_RSA_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_ECDH_RSA_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_RSA_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_RSA_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_DH_RSA_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_DH_RSA_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_DH_DSS_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_DH_DSS_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_DH_anon_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_DH_anon_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_ECDH_ECDSA_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_ECDH_ECDSA_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_ECDH_RSA_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_ECDH_RSA_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_PSK_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_PSK_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_RSA_PSK_WITH_CAMELLIA_128_GCM_SHA256',
    'TLS_RSA_PSK_WITH_CAMELLIA_256_GCM_SHA384',
    'TLS_PSK_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_PSK_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_DHE_PSK_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_DHE_PSK_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_RSA_PSK_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_RSA_PSK_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_ECDHE_PSK_WITH_CAMELLIA_128_CBC_SHA256',
    'TLS_ECDHE_PSK_WITH_CAMELLIA_256_CBC_SHA384',
    'TLS_RSA_WITH_AES_128_CCM',
    'TLS_RSA_WITH_AES_256_CCM',
    'TLS_RSA_WITH_AES_128_CCM_8',
    'TLS_RSA_WITH_AES_256_CCM_8',
    'TLS_PSK_WITH_AES_128_CCM',
    'TLS_PSK_WITH_AES_256_CCM',
    'TLS_PSK_WITH_AES_128_CCM_8',
    'TLS_PSK_WITH_AES_256_CCM_8'
  ]

  @impl true
  def connect(host, port, opts) do
    ssl_opts =
      default_ssl_opts()
      |> Keyword.merge(opts)
      |> update_ssl_opts(host)

    host
    |> String.to_charlist()
    |> :ssl.connect(port, ssl_opts)
  end

  @impl true
  defdelegate negotiated_protocol(socket), to: :ssl

  @impl true
  def send(socket, payload) do
    with :ok <- :ssl.send(socket, payload) do
      {:ok, socket}
    end
  end

  @impl true
  def close(socket) do
    with :ok <- :ssl.close(socket) do
      {:ok, socket}
    end
  end

  @impl true
  def recv(socket, bytes) do
    with {:ok, data} <- :ssl.recv(socket, bytes) do
      {:ok, data, socket}
    end
  end

  @impl true
  defdelegate setopts(socket, opts), to: :ssl

  @impl true
  defdelegate getopts(socket, opts), to: :ssl

  defp update_ssl_opts(opts, host_or_ip) do
    verify = Keyword.get(opts, :verify)
    verify_fun_present? = Keyword.has_key?(opts, :verify_fun)

    if verify == :verify_peer and not verify_fun_present? do
      reference_ids =
        case Keyword.fetch(opts, :server_name_indication) do
          {:ok, server_name} ->
            [dns_id: server_name]

          :error ->
            host_or_ip = to_charlist(host_or_ip)
            [dns_id: host_or_ip, ip: host_or_ip]
        end

      Keyword.put(opts, :verify_fun, {&verify_fun/3, reference_ids})
    else
      opts
    end
  end

  def verify_fun(_, {:bad_cert, _} = reason, _), do: {:fail, reason}
  def verify_fun(_, {:extension, _}, state), do: {:unknown, state}
  def verify_fun(_, :valid, state), do: {:valid, state}

  def verify_fun(cert, :valid_peer, state) do
    if :xhttp_shims.pkix_verify_hostname(cert, state, match_fun: &match_fun/2) do
      {:valid, state}
    else
      {:fail, {:bad_cert, :hostname_check_failed}}
    end
  end

  # Wildcard domain handling for DNS ID entries in the subjectAltName X.509
  # extension. Note that this is a subset of the wildcard patterns implemented
  # by OTP when matching against the subject CN attribute, but this is the only
  # wildcard usage defined by the CA/Browser Forum's Baseline Requirements, and
  # therefore the only pattern used in commercially issued certificates.
  defp match_fun({:dns_id, reference}, {:dNSName, [?*, ?. | presented]}) do
    case domain_without_host(reference) do
      '' ->
        :default

      domain ->
        # TODO: replace with `:string.casefold/1` eventually
        :string.to_lower(domain) == :string.to_lower(presented)
    end
  end

  defp match_fun(_reference, _presented), do: :default

  defp domain_without_host([]), do: []
  defp domain_without_host([?. | domain]), do: domain
  defp domain_without_host([_ | more]), do: domain_without_host(more)

  defp default_ssl_opts() do
    [
      verify: :verify_peer,
      ciphers: default_ciphers()
    ]
  end

  defp default_ciphers() do
    blacklisted_ciphers = Enum.map(@blacklisted_ciphers, &list_to_cipher/1)
    :ssl.cipher_suites() -- blacklisted_ciphers
  end

  defp list_to_cipher(name) do
    "TLS_" <> rest = List.to_string(name)
    {key_algo, rest} = key_algo_part(rest)
    {cipher, rest} = cipher_part(rest)
    hashes = hash_part(rest)
    ([key_algo, cipher] ++ hashes)
    |> Enum.map(&String.to_atom(String.downcase(&1)))
    |> List.to_tuple()
  end

  defp key_algo_part(name) do
    [key_algo, rest] = String.split(name, "_WITH_", parts: 2)
    {key_algo, rest}
  end

  defp cipher_part("NULL_" <> rest), do: {"NULL", rest}

  defp cipher_part(name) do
    cipher_parts = String.split(name, "_", parts: 4)
    {cipher_parts, [rest]} = Enum.split(cipher_parts, -1)
    {Enum.join(cipher_parts, "_"), rest}
  end

  defp hash_part(name) do
    String.split(name, "_", parts: 2)
  end
end
