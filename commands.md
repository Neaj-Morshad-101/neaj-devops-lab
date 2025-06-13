This command removes all local branches that no longer have a corresponding remote branch: If any branch refuses to delete due to unmerged changes, force delete it with `git branch -D`
git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d

`kubectl logs <db-pod-0> -n <db-namespace> --all-containers=true`