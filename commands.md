# Git 
This command removes all local branches that no longer have a corresponding remote branch: If any branch refuses to delete due to unmerged changes, force delete it with `git branch -D`
`git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d`

Unstage a staged files:
```
git restore --staged <file>
git restore --staged .
```


# Kubernetes 
pod logs:
`kubectl logs <db-pod-0> -n <db-namespace> --all-containers=true`


# Docker 
docker system prune --all

# Others
VS Code update: If you already have an older version installed:
`sudo dpkg -i code_<version>_amd64.deb`
Fix dependencies (if needed)
`sudo apt-get install -f`
