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
To unstage a staged file befor commit use
```
git rm --cached <file>
