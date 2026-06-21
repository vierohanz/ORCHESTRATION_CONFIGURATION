.PHONY: ping deploy teardown

ping:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible all -m ping --ask-vault-pass

deploy:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook playbooks/site.yml --ask-vault-pass

teardown:
	cd ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook playbooks/teardown.yml --ask-vault-pass
