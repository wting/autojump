#!/usr/bin/env python

import cPickle
import os.path
import pygtk
pygtk.require('2.0')
import gtk

def load_paths(filename="~/.autojump_py",maxpath=10):
    dic_file=os.path.expanduser("~/.autojump_py")

    try:
        aj_file=open(dic_file)
        path_dict=cPickle.load(aj_file)
        aj_file.close()
    except IOError:
        pass

    path_dict=path_dict.items()
    path_dict.sort(key=lambda x: x[1],reverse=True)

    return [path for path,score in path_dict[:maxpath]]

class Action:
    def __init__(self,name,path):
        self.name=name
        self.path=path

    #insert other actions here
    def _unknown(self):
        print "unknown action %s for %s" % (self.name,self.path)
    def terminal(self):
        print "terminal %s" % self.path
    def nautilus(self):
        print "nautilus %s" % self.path

    def __call__(self):
        getattr(self,self.name,self._unknown)()

def get_actions():
    return [name for name,value in Action.__dict__.items() if callable(value) and name[0]!='_' ]

def popup(sender,button,activation):
    paths=load_paths()

    actions=get_actions()
    menu=gtk.Menu()
    for path in paths:
        item=gtk.MenuItem(path)
        submenu=gtk.Menu()
        item.set_submenu(submenu)
        for action in actions:
            subitem=gtk.MenuItem(action)
            subitem.connect("activate",menuitem,Action(action,path))
            submenu.append(subitem)
        menu.append(item)

    menu.append(gtk.SeparatorMenuItem())
    
    item=gtk.MenuItem("quit")
    item.connect("activate",quit)
    menu.append(item)

    menu.show_all()
    menu.popup(None,None,gtk.status_icon_position_menu,button,activation,sender)

def menuitem(sender,functionnality):
    functionnality()

def init():
    icon=gtk.status_icon_new_from_file("icon.png")
    icon.set_visible(True)
    icon.connect("popup-menu",popup)

def quit(sender):
    gtk.main_quit()

if __name__=='__main__':
    init()
    gtk.main()
