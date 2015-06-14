#!/usr/bin/env python3
import platform
import sys
import os
import shutil
import datetime

def main():
    if len(sys.argv) > 1:
        op = sys.argv[1]
    else:
        help()

    if len(sys.argv) > 2:
        target = sys.argv[2]
    else:
        target = ''
    
    if op in ['deploy', 'd', 'collect', 'c']:
        if target != '':
            deploy(op, target)
        else:
            print("[x] Missing target.")
    elif op in ['pull', 'push', 'l','h']:
        sync(op)
    elif op in ['help', 'h']:
        help()
    else:
        print("[x] Unknown operation")

def help():
    helpstr = [ 'sync'
              , 'python sync.py [operation]'
              , 'python sync.py [operation] [target]'
              , 'operation:'
              , '    deploy   [target]: copy target\'s profiles form repo to local'
              , '    collect  [target]: copy target\'s profiles form local to repo'
              , '    push:    push profiles to reomote repo '
              , '    pull:    pull profiles form reomote repo '
              , 'target:'
              , '    vim'
              , '    zsh'
              , '    pen(pentadactyl)'
              , 'Python 3 require, by LastAvengers'
              ]
    list(map(print, helpstr))

def deploy(op, target):
    path = []
    
    if os.name == 'posix':
        home = os.path.expanduser('~')
    else:
        home = os.path.expanduser('USERPROFILE')

    if target == 'vim':
        if os.name == 'posix':
            path.append((os.path.join(home,'.vimrc'),'./_vimrc'))
    elif target == 'pen':
        if os.name == 'posix':
            path.append((os.path.join(home, '.pentadactylrc') , './_pentadactylrc'))
        else:
            path.append(( os.path.join(home, '_pentadactylrc'), '.\\_pentadactylrc'))
    elif target == 'zsh':
        if os.name == 'posix':
            path.append((os.path.join(home,'.zshrc'),'./_zshrc'))
            path.append((os.path.join(home,'.oh-my-zsh'),'./_oh-my-zsh'))
    else:
        print("[x] Unknown target")
        exit()

    if op in ['deploy','d']:
        path = list(map(lambda x:(x[1],x[0]), path))

    print(list(path))
    list(map(copy, path))
    print('[*] Finished')

def copy(p):
    src = p[0] 
    dest = p[1]

    if not os.path.exists(src):
        print('[x] Target dose not exist')
    if os.path.isfile(src):
        shutil.copyfile(src,dest)
        print('[+] Copy file ' + src + ' -> ' + dest)
    elif os.path.isdir(src):
        tmpdir = os.path.join(os.path.dirname(dest),'.synctmp')
        if os.path.exists(dest):
            os.rename(dest, tmpdir)
        shutil.copytree(src, dest)
        if os.path.exists(tmpdir):
            shutil.rmtree(tmpdir)
        print('[+] Copy directory ' + src + ' -> ' + dest)

def sync(op):
    if op in ['push', 'h']:
        commitlog = str(datetime.datetime.now())
        print('[+] git add .')
        os.system('git add .')

        print('[+] git commit -m \"' + commitlog + '\"')
        os.system('git commit -m \"' + commitlog + '\"')

        print('[+] git push')
        os.system('git push')

    if op in ['pull','l']:
        print('[+] git pull')
        os.system('git pull')

if __name__ == "__main__":
    main()
