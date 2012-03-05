#!/bin/bash -xe
if [ ! -e /opt/opscode/.branch ]; then exit 1; fi
GIT_BRACH_CLEAN="$(git describe --all --match "heads/.*" | sed s/heads\\/// | tr / _)"
if [ -z "$GIT_BRANCH_CLEAN" ]; then exit 1; fi
if [ "$GIT_BRANCH_CLEAN" != "$(cat /opt/opscode/.branch)" ]
then
  sudo mv /opt/opscode "/opt/opscode-$(cat /opt/opscode/.branch)"
  if [ ! -d "/opt/opscode-$GIT_BRANCH_CLEAN" ]; then sudo mkdir "/opt/opscode-$GIT_BRANCH_CLEAN"; fi
  sudo mv "/opt/opscode-$GIT_BRANCH_CLEAN" /opt/opscode
fi
sudo env CHEF_SOLO_COOKBOOKS="$(pwd)/cookbooks" chef-solo -c /srv/opscode-omnibus/shared/solo.rb -j /srv/opscode-omnibus/shared/solo.json
cp omnibus.rb.example omnibus.rb
rm pkg/* || true
bundle install --deployment --without development
bundle exec rake projects:private-chef:deb