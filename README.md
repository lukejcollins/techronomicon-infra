[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?logo=terraform&logoColor=white&labelColor=623CE4&color=white&labelWidth=20&labelHeight=20)](https://www.terraform.io/) [![AWS](https://img.shields.io/badge/AWS-Amazon%20Web%20Services-232F3E?logo=amazon-aws&logoColor=white&labelColor=232F3E&color=orange&labelWidth=20&labelHeight=20)](https://aws.amazon.com/) ![Terraform](https://github.com/lukejcollins/techronomicon-infra/actions/workflows/terraform.yml/badge.svg)

# 🧙‍♂️ The Enchanting Techronomicon Infrastructure with Terraform 🏰

Welcome, intrepid explorer! Are you ready to journey through the mystical realm of AWS using the ancient arts of Terraform? This magical codex can summon a kingdom of services for the illustrious Techronomicon.

## 📜 Codex Overview 

Peek into this mystical codex to reveal:

- The grand realm of `my_vpc`, sprawling across the `10.0.0.0/16` magic quadrant.
- Two bustling public hamlets: `my_public_subnet1` and `my_public_subnet2`.
- An eldritch portal `my_igw` connecting our realm to the world beyond (The Internet).
- The `my_route_table`, a map guiding wanderers across our townships.
- An arcane chest of knowledge, an RDS PostgreSQL database `db`.
- An ECS IAM role `ecs_task_execution_role`, a trusted attendant to our ECS tasks.
- A cloud stronghold, the `techronomicon-instance`.
- A battalion of the bravest cloud warriors, gathered in the `techronomicon-cluster`.
- The `techronomicon` CloudWatch Log Group, ever-watchful of the realm's affairs.
- A rallying call in the form of an ECS task definition `task` and an ECS service `service`.
- A Route 53 hosted zone for `lukecollins.dev`, complete with an `A` record, our banner on the map of the cloud.

Our kingdom resides in the `eu-west-1` realm, and its tale is recorded in an S3 bucket, where time stands still.

## 🧝‍♀️ Prepare for Your Adventure

To decipher and command this Terraform codex, you'll need the power of Terraform installed on your arcane slab (computer). You must also be recognized by the AWS realm with your credentials at hand.

Please be sure to conjure the following arcane symbols (environment variables):

## 🧙‍♂️ Terraform Incantations

The runes inscribed here can create, change or destroy your cloud kingdom at will. 

- `terraform init`: Awaken the Terraform spirits in your local chamber.
- `terraform plan`: Peer into the potential future of your kingdom.
- `terraform apply`: Let your will be done and shape your cloud realm.
- `terraform destroy`: Unmake your creations, returning the cloud to its primal state.

## 🕯️ GitHub Actions Ritual

With the aid of the GitHub Actions spirits, your spells can be chanted automatically when your magical tome (the code) is altered. Keep a watchful eye on the actions tab in your GitHub repository for the results of the ritual.

## 📣 Heed These Words

Practice the art of safe spellcasting. Never wield Terraform lightly, for its powers are great and can bring both creation and ruin. To avoid unsanctioned changes, make use of the `terraform plan` incantation to foresee the consequences of your spells.

Be brave, be bold, and enjoy your mystical journey through the realm of Terraform!
