.PHONY: ping deploy teardown

ping:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible all -m ping

deploy:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook playbooks/site.yml

teardown:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook playbooks/teardown.yml

tf-init:
	cd terraform && ./terraform.exe init

tf-plan:
	cd terraform && ./terraform.exe plan

tf-apply:
	cd terraform && ./terraform.exe apply

tf-destroy:
	cd terraform && ./terraform.exe destroy
