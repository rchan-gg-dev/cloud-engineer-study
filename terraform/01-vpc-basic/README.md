# Terraform AWS VPC Basic

## 1. 目的
Terraformを利用して、AWS上にVPC、Subnet、Route Table、
Security Group、EC2を構成する。

Public / Private Subnetの役割や通信経路を理解し、
TerraformによってAWS環境を再現できることを目的とする。

## 2. 構成概要
VPC内にPublic SubnetとPrivate Subnetを作成し、
2つのAvabilitity ZoneにそれぞれSubnetを配置する。

現在はPublic Subnet AにPublic EC2を1台、
Private Subnet AにPrivate EC2を1台配置している。

Public EC2にはPublic IPを付与し、
HTTP 80を0.0.0.0/0から許可、
SSH 22を自宅のグローバルIP/32から許可する。

Private EC2にはPublic IPを付与しない。

Private EC2のSSH 22は、
Public EC2に関連付けられたSecurity Groupを
送信元として許可する。

Private EC2へはPublic EC2を踏み台としてSSH接続する。

Public / Private Subnet Bは、
今後の冗長構成を想定して作成している。

## 3. ネットワーク設計
■VPC
CIDR：10.10.0.0/16　
用途：学習用VPC 

■Subnet
◇Public Subnet A
CIDR：10.10.1.0/24
用途：Public EC2配置用

◇Public Subnet B
CIDR：10.10.2.0/24
用途：将来の冗長構成用

◇Private Subnet A
CIDR：10.10.11.0/24
用途：Private EC2配置用

◇Private Subnet B
CIDR：10.10.12.0/24
用途：Private EC2配置用

■Route Table
◇Public
CIDR：0.0.0.0/0
接続先：Internet Gateway

◇Private
CIDR：10.10.0.0/16
接続先：local

・Private Route Tableには0.0.0.0/0がないため、
Private EC2はInternetへ直接通信できない。

## 4. セキュリティ設計

### Public EC2

HTTP 80  
Source: 0.0.0.0/0

SSH 22  
Source: 自宅のグローバルIP /32

### Private EC2

SSH 22  
Source: Public EC2に関連付けられたSecurity Group

Private EC2へのSSHは、
Public EC2のPrivate IPを直接指定するのではなく、
Public EC2に関連付けられたSecurity Groupを送信元として許可する。

これにより、Public EC2のPrivate IPが変更された場合でも
Security Groupのルールを変更する必要がなく、
EC2の役割単位でアクセス制御を行える。

## 5. Terraformで管理しているリソース
| 種別 | Terraform上の名前 | AWS上の名前 / 用途 |
|---|---|---|
| VPC | aws_vpc.main | terraform-study-vpc |
| Public Subnet A | aws_subnet.public_a | Public EC2配置用 |
| Public Subnet B | aws_subnet.public_b | 将来の冗長構成用 |
| Private Subnet A | aws_subnet.private_a | Private EC2配置用 |
| Private Subnet B | aws_subnet.private_b | 将来の冗長構成用 |
| Internet Gateway | aws_internet_gateway.main | VPCのInternet接続用 |
| Public Route Table | aws_route_table.public | 0.0.0.0/0 → IGW |
| Private Route Table | aws_route_table.private | local通信のみ |
| Public EC2 SG | aws_security_group.public_ec2 | Public EC2用 |
| Private EC2 SG | aws_security_group.private_ec2 | Private EC2用 |
| Public EC2 | aws_instance.public | terraform-study-public-ec2 |
| Private EC2 | aws_instance.private | terraform-study-private-ec2 |

## 6. 接続方法

### Public EC2へのSSH接続

`terraform output`からPublic IPを取得する。

```bash
PUBLIC_IP=$(terraform output -raw public_ec2_public_ip)
```

Public EC2へSSH接続する。

```bash
ssh -i ~/.ssh/cloud-study-key.pem ec2-user@"$PUBLIC_IP"
```
### Private EC2へのSSH接続

`terraform output`からPublic EC2のPublic IPと、
Private EC2のPrivate IPを取得する。

```bash
PUBLIC_IP=$(terraform output -raw public_ec2_public_ip)
PRIVATE_IP=$(terraform output -raw private_ec2_private_ip)
```

```bash
ssh \
  -i ~/.ssh/cloud-study-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/cloud-study-key.pem -W %h:%p ec2-user@$PUBLIC_IP" \
  ec2-user@"$PRIVATE_IP"
```
Private EC2にはPublic IPを付与していないため、
インターネットから直接SSH接続することはできない。

## 7. 動作確認
### Terraform
以下を実行し、Terraform Configurationに問題がないことを確認した。

```bash
terraform fmt
terraform validate
terraform plan
```
`terraform plan`では意図しないResourceの変更・削除が
発生しないことを確認してから`terraform apply`を実行した。

### Public EC2
User Dataによって以下が自動実行されていることを確認した。

- Apache HTTP Serverのインストール
- index.htmlの作成
- httpdの起動
- OS起動時のhttpdの自動起動設定

以下のコマンドで確認した。
```bash
sudo cloud-init status
systemctl status httpd --no-pager
systemctl is-enabled httpd
sudo ss -lntp | grep ':80'
cat /var/www/html/index.html
curl -I http://127.0.0.1
```

### Private EC2
Private EC2にPublic IPが付与されていないことを確認した。

Public EC2を踏み台として、PrivateEC2へSSH接続できることを確認した。

Private EC2上で以下を確認した。
```bash
hostname
ip -br addr
ip route
```
Private Route TableにはInternet向けの
`0.0.0.0/0` Routeが存在しないため、
Private EC2からInternetへ通信できないことを確認した。
```bash
curl -I --connect-timeout 5 https://example.com
```
結果 :
```
Connection timed out
```
AWS CLIでもPrivate Route Tableを確認し、
`10.10.0.0/16 -> local`のみ存在することを確認した。

## 8. トラブルシューティング

### cloud-init statusでPermission denied
一般ユーザーで以下を実行したところ、
cloud-initのConfiguration Fileを読み取れず、Permission deniedとなった。
```bash
cloud-init status
```
権限不足のため、
`sudo`を付けて実行することで確認できた。
```bash
sudo cloud-init status
```

### EC2停止後にterraform planでPublic EC2の再作成が表示された
Public EC2の課金を止めるため、Public EC2を停止。
Public EC2を停止した状態で`terraform plan`を実行したところ、
Public EC2のReplacementが表示された。

EC2停止によって自動割り当て Public IPが外れ、
Terraform Configurationとの差分として検出されたためだった。

Public EC2を再起動してから、`terraform plan`を実行すると、
不要なReplacementは表示されなくなった。

### ProxyJumpでPrivate EC2へ接続できない
`ssh -J`を使用したところ、
踏み台となるPublic EC2で秘密鍵の認証に失敗した。

ProxyCommandでPublic EC2側にも使用する秘密鍵を明示することで接続することができた。
```bash
ssh \
  -i ~/.ssh/cloud-study-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/cloud-study-key.pem -W %h:%p ec2-user@$PUBLIC_IP" \
  ec2-user@"$PRIVATE_IP
```

## 9. 学んだこと
- Terraformの variable、data、resource、output の役割
- TerraformによるVPC / Subnet / Route Table / Security Group / EC2の構築
- Terraform Resource間の参照による依存関係
- User Dataとcloud-initを利用したEC2初期設定
- Public SubnetとPrivate Subnetの通信経路の違い
- Security Groupを送信元として使用するアクセス制御
- Public EC2を踏み台としたPrivate EC2へのSSH接続
- LinuxのRouting TableとAWS VPC Route Tableの違い
- terraform plan で意図しない変更や削除を確認する重要性
- AWS CLIを利用した実環境の確認

## 10. 構成図

![AWS Architecture](images/architecture.png)