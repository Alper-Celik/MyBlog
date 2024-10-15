---
title: Self Hosting Vaultwarden and Setting up SSL Certificates under Tailscale in Nixos
date: 2024-10-15
comments:
  host: infosec.exchange
  username: Alper_Celik
  id: 113311051453017156 
---

I have been using [pass][pass] but since i am experimenting with selfhosting and 
wanted to store passkeys inside my password manager i wanted to selfhost [Vaultwarden][vaultwarden]
(a [Bitwarden][bitwarden] server implementation) server but i didn't wanted to expose it to internet
so i wanted to use my [Tailscale][tailscale] network.

so i added required config to my [Raspberry 5][rpi5]'s [Nixos][nixos] config
```nix
services.vaultwarden = {
   enable = true;
};
```
and now i needed an easier way to access it then with ip and port so i needed to setup a reverse proxy like nginx,
since i am using [Tailscale][tailscale] i wanted to use [MagicDNS][mdns++] feature of it but after looking at it
i noticed i can't use subdomains in it to host multiple services insede one machine since i want to try to selfhost
things like nextcloud too on that machine i decided to not use [MagicDNS][mdns++] to access my services.

Since i have a domain i decided to use that and point to static [Tailscale][tailscale] ip of [Vaultwarden][vaultwarden] server
but my domain uses [HSTS][hsts] and HTTPS needded for [some feutures of Bitwarden][https-warning] so i needed SSL Certificates for my [Vaultwarden][vaultwarden] instance.

It would have been easy if it were a service exposed to the internet since [Nixos][nixos] has support for automatically getting certificate from [Let's Encrypt][LE]
and automatically renewing them but it uses [HTTP-01 challenge][challenges] by default to prove ownership of the domain so i needed a better solution since the IP of the domain wasn't exposed to the internet.
Solution was using [DNS-01 challenge][challenges] since it uses dns records to prove ownership it doesn't need the domain to be accessible from the internet and the best part is Nixos supported using [DNS-01 challenge][challenges]
when configured with dns api key etc.

I added my cloudflare api key to my [sops-nix][sops] repo and added them to my rpi5 secrets definitions:
```nix
sops = {
  secrets = {
    CLOUDFLARE_API_KEY = { };
    CLOUDFLARE_EMAIL = { };
  };
};
```
and then configured acme settings to use [DNS-01 challenge][challenges]:
```nix
security.acme = {
  acceptTerms = true;
  defaults = {
    email = "alper@alper-celik.dev";
    dnsProvider = "cloudflare";
    credentialFiles =
      let
        s = config.sops.secrets;
      in
      {
        CLOUDFLARE_API_KEY_FILE = s.CLOUDFLARE_API_KEY.path;
        CLOUDFLARE_EMAIL_FILE = s.CLOUDFLARE_EMAIL.path;
      };
    dnsResolver = "1.1.1.1:53";
  };
};
```
and lastly i added [Nginx][nginx] reverse proxy config:
```nix
services.nginx.enable = true;
services.nginx.virtualHosts."bitwarden.lab.alper-celik.dev" = {
  enableACME = true;
  forceSSL = true;
  locations."/" = {
    proxyPass = "http://localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}";
  };
};
```
Then i deployed my changes and it didn't used [DNS-01 challenge][challenges] and failed,
after a bit of digging i found out i needed to set `acmeRoot` to `null` so i added that:
```nix
services.nginx.virtualHosts."bitwarden.lab.alper-celik.dev".acmeRoot = null;
```
After deploying again i had access to it inside my [Tailscale][tailscale] network.

But i wasn't over yet, i still needed to migrate 30 or so passwords from [pass][pass], after searching a bit i came across this python script: [pass2bitwarden][pass2bw] after 
reviewing its code i converted my password store to bitwarden format and it migrated almost everything including 2fa codes but it didn't migrated custom fields so i manually migrated them.

and that was it. I now had a bit more polished password manager that i hosted. It was fun to setup.

[pass]:https://www.passwordstore.org/
[vaultwarden]:https://github.com/dani-garcia/vaultwarden
[bitwardem]:https://bitwarden.com/
[tailscale]:https://bitwarden.com/
[rpi5]:https://www.raspberrypi.com/products/raspberry-pi-5/
[nixos]:https://nixos.org/
[mdns++]:https://tailscale.com/kb/1081/magicdns
[hsts]:https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
[https-warning]:https://github.com/dani-garcia/vaultwarden?tab=readme-ov-file#installation
[LE]:https://letsencrypt.org/
[challenges]:https://letsencrypt.org/docs/challenge-types/
[sops]:https://github.com/Mic92/sops-nix
[nginx]:https://nginx.org/en/
[pass2bw]:https://github.com/quulah/pass2bitwarden
