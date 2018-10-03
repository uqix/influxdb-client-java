#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

#!/usr/bin/env bash

set -e

echo ${TRAVIS_REPO_SLUG}
echo ${TRAVIS_PULL_REQUEST}
echo ${TRAVIS_BRANCH}

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ "$TRAVIS_REPO_SLUG" == "bonitoo-io/influxdata-platform-java" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then

    # Generate Site
    docker run -it --rm --volume ${SCRIPT_PATH}/../:/usr/src/mymaven --volume ${SCRIPT_PATH}/../.m2:/root/.m2 --workdir /usr/src/mymaven maven:${MAVEN_JAVA_VERSION} mvn site site:stage
    cp -R ${SCRIPT_PATH}/../target/staging ${HOME}/site

    # Clone GitHub pages
    cd ${HOME}
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "travis-ci"
    git clone --quiet --branch=gh-pages https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG} ${HOME}/gh-pages > /dev/null

    # Push Site
    rm -rf ${HOME}/gh-pages/*
    cd ${HOME}/gh-pages
    ls
    cp -Rf ${HOME}/site/* ./
    ls
    git add -f .
    git commit -m "Pushed the latest Maven site to GitHub pages"
    git push -fq origin gh-pages > /dev/null

fi
