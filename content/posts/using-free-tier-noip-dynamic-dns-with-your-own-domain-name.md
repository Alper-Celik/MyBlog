---
title: "Using Free Tier Noip Dynamic Dns with Your Own Domain Name"
date: 2024-05-09
comments:
  host: infosec.exchange
  username: Alper_Celik
  id: 112411892438459287
---
Since getting myself a raspbery pi 5 and getting a proper internet infrastructure 
at home i wanted to get into some form of selfhosting.
but not having static ip prevented me from having an easy way to access raspbery pi
from internet.

i did try to not care at first but ip address changes every several 
days and that forces me to update it regularly.

as a solution i looked at the dynamic dns services and no-ip had 
free tier option but in free tier you have to use a domain name under their domain
like `example.ddns.net`

I didn't wanted to use their domain name so i didn't manualy updated my ip address when 
things broke for a while

after some thinking i remembered i needed to set `CNAME` 
records for setting up github pages on my domain name so i looked at what exactly is 
`CNAME` records are and read the [awesome blogpost][1] by Cloudflare explaining what they are.

so `CNAME` records allows you to point that domain to ip address of another domain name so my 
`CNAME` record pointing at `alper-celik.github.io` will resove ip of `alper-celik.github.io`
and use that ip address to acces my domain.

also good thing is since webservers get the domain you'r coming from they can serve different 
content to different domains from same ip address.

so i created free tier no-ip account and set it up according to the [getting started guide][2] and then
i added `CNAME` record pointing my domain to their dynamic domain so by doing that i have dynamic dns under
my domain name using no-ip's free tier

[1]: https://www.cloudflare.com/learning/dns/dns-records/dns-cname-record/
[2]: https://www.noip.com/support/knowledgebase/free-dynamic-dns-getting-started-guide-ip-version
