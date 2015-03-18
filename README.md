A fork of http://code.dogmap.org/spftools/ and http://code.dogmap.org/sptools/ . Most of the documentation can be found there.

### If you just want to try out some existing binaries

This now allows anyone else who has access to install the binary, but the only difference is that the binaries are symlinked to /package/host/yourdomain/foreign/command/ instead of /command/. To try out openssh, from an existing binary, just do the following:
{% highlight yaml %}
git clone https://github.com/tjheeta/slashpackage-installer
cd slashpackage-installer
mkdir /usr/local/package
ln -s /usr/local/package /package
# The openssh directories need to be owned by root so needs to be run with sudo
sudo ./spf-binary /package/host/spf.fxmanifold.com/foreign/openssh
sudo /package/host/spf.fxmanifold.com/command/sshd -D -f /etc/ssh/sshd_config  -p 2222
{% endhighlight %}

Note that if you get errors like "User someuser not allowed because account is locked", that means you need to modify /etc/shadow to remove the ! symbols. For instance 
ubuntu:!:16480:0:99999:7::: should become 
ubuntu:*:16480:0:99999:7:::

### Setup your own repository - (optional)
Let's say you want to setup your own repository of snippets and binaries. On your webserver, make this directory available which contains snippets of build scripts.
{% highlight yaml %}
cd /path/to/html
git clone https://github.com/tjheeta/slashpackage-foreign
{% endhighlight %}

It should be accessible via http://yourhost/slashpackage-foreign/

### Setup a host to compile on 
After this, you can go to your target host and either compile binaries or installed pre-compiled. I would suggest using the included Vagrantfile.
{% highlight yaml %}
git clone slashpackage-installer
cd slashpackage-installer
vagrant up
vagrant ssh
cd /vagrant/
{% endhighlight %}

If you don't want to use vagrant, then there is a script "machine-setup.sh", which will make the directories.

### Setup the toolchain to use musl
If you want to compile everything against musl, do the following which will setup gcc to use musl. All the following examples will use the snippets at spf.fxmanifold.com, and there are some older packages available at [http://code.dogmap.org./slashpackage-foreign/][slashpackage]. 
{% highlight yaml %}
sudo -s
export PATH=/command:$PATH:/vagrant
SP_COMPAT=n ./spf-install /package/host/spf.fxmanifold.com/foreign/musl
cd /command
mv gcc-wrapper gcc
mv cc-wrapper cc
{% endhighlight %}

And to install a package - for instance openssh compiled against libressl:
{% highlight yaml %}
SP_COMPAT=n ./spf-install /package/host/spf.fxmanifold.com/foreign/openssh
{% endhighlight %}

This will install OpenSSH into /package/host/spf.fxmanifold.com/foreign/openssh/command and all the binaries symlinked into /command/. The binaries are symlinked only against /package:
{% highlight yaml %}
$ ldd /command/sshd
/package/host/spf.fxmanifold.com/foreign/musl-1.1.6+spf+1/prefix/lib/libc.so (0x7f7313d57000)
libcrypto.so.32 => /package/host/spf.fxmanifold.com/foreign/openssh-6.7p1+spf+0/conf/libressl/library/libcrypto.so.32 (0x7f7313955000)
libz.so.1 => /package/host/spf.fxmanifold.com/foreign/openssh-6.7p1+spf+0/conf/zlib/library/libz.so.1 (0x7f731373c000)
libc.so => /package/host/spf.fxmanifold.com/foreign/musl-1.1.6+spf+1/prefix/lib/libc.so (0x7f7313d57000)
{% endhighlight %}

Now you can go a bit further than this and publish your binaries on your webserver:
{% highlight yaml %}
cd slashpackage-installer
./spf-publish /package/host/spf.fxmanifold.com/foreign/openssh-6.7p1+spf+0/
rsync -av -e ssh /package/host/spf.fxmanifold.com/dist spf.fxmanifold.com:/path/to/slashpackage-foreign
{% endhighlight %}

This is then consumed by the spf-binary command, which was the first example.
