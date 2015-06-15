#!/usr/bin/env python3
import platform
import sys
import os
import shutil
import datetime

g_op = ['deploy', 'collect', 'add', 'pull', 'push','help']
g_target = ['all','vim','zsh','pen']

def main():
    if len(sys.argv) > 1:
        op = sys.argv[1]
        if not op in g_op:
            print('[x] Unknown operation ' + op)
            exit()
    else: 
        help()

    if len(sys.argv) > 2:
        target = sys.argv[2]
        if not target in g_target:
            print('[x] Unknown target ' + target)
            exit()
    else:
        target = ''

    if op in ['deploy', 'collect']:
        if target != '':
            deploy(op, target)
        else:
            print('[x] Missing target.')
    elif op in ['add', 'pull', 'push']:
        sync(op)
    else:
        help()
    print('[*] Finished')


def deploy(op, target):
    path = []
    home = os.path.expanduser('~')

    if target == 'vim':
        if os.name == 'posix':
            path.append((os.path.join(home,'.vimrc'),'./_vimrc'))
            path.append((os.path.join(home,'.vim'),'./vimfiles'))
        else:
            path.append((os.path.join(home,'_vimrc'),'.\\_vimrc'))
            path.append((os.path.join(home,'vimfiles'),'.\\vimfiles'))

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
            print('[*] Target zsh is unavailable in windows')
    elif target == 'all':
        list(map(lambda x: deploy(op,x),g_target[1:]))
        return

    if op in ['deploy','d']:
        path = list(map(lambda x:(x[1],x[0]), path))

    # print(list(path))
    list(map(copy, path))

def copy(p):
    src = p[0] 
    dest = p[1]

    try:
        if not os.path.exists(src):
            print('[x] ' + src + ' dose not exist')
            return

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
    except Exception as e:
        print(e)
        print('[x] Fault while processing' + src + ' -> ' + dest)

def sync(op):
    if op == 'add':
        print('[+] git add .')
        os.system('git add .')
        os.system('git diff')

    if op == 'push':
        commitlog = str(datetime.datetime.now())
        print('[+] git commit -m \"' + commitlog + '\"')
        os.system('git commit -m \"' + commitlog + '\"')
        print('[+] git push')
        os.system('git push')

    if op == 'pull':
        print('[+] git pull')
        os.system('git pull')

def help():
    helpstr = [ 'sync   -- a simple script used to sync profile'
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
              , '    all = vim + zsh + pen'
              , 'require: python3 or above, git'
              ]
    list(map(print, helpstr))
    exit()

if __name__ == '__main__':
    main()
