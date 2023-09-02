{ ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "mib@mib.dev";
      #server = "https://acme-v02.api.letsencrypt.org/directory";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # defaults to production; testing should be done with staging
      # https://acme-staging-v02.api.letsencrypt.org/directory
    };
  };
}
