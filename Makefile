.PHONY: ping deploy

ping:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible all -m ping

deploy:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook playbooks/site.yml
