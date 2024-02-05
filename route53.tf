data "aws_route53_zone" "crypticnet" {
  name = "cryptic.net"
}

resource "aws_route53_record" "rockset" {
  zone_id = data.aws_route53_zone.crypticnet.zone_id
  name    = "rockset.${data.aws_route53_zone.crypticnet.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_ingress_v1.rockset.status[0].load_balancer[0].ingress[0].hostname]
}
