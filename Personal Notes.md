Ansible Ping
```
ansible webserver -i host-inventory -m ping -u ubuntu
```

Ansible Deploy
```
ansible-playbook -i host-inventory book.yml -u ubuntu --check
```
```
ansible-playbook -i host-inventory book.yml -u ubuntu
```
