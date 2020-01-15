<p align="center">
  <a href="https://nodejs.org/">
    <img
      alt="Node.js"
      src="https://nodejs.org/static/images/logo-light.svg"
      width="400"
    />
  </a>
</p>

Node.js is an open-source, cross-platform, JavaScript runtime environment. It
executes JavaScript code outside of a browser. For more information on using
Node.js, see the [Node.js Website][].

The Node.js project uses an [open governance model](./GOVERNANCE.md). The
[OpenJS Foundation][] provides support for the project.

**This project is bound by a [Code of Conduct][].**

# Table of Contents

* [Support](#support)
* [Release Types](#release-types)
  * [Download](#download)
    * [Current and LTS Releases](#current-and-lts-releases)
    * [Nightly Releases](#nightly-releases)
    * [API Documentation](#api-documentation)
  * [Verifying Binaries](#verifying-binaries)
* [Building Node.js](#building-nodejs)
* [Security](#security)
* [Contributing to Node.js](#contributing-to-nodejs)
* [Current Project Team Members](#current-project-team-members)
  * [TSC (Technical Steering Committee)](#tsc-technical-steering-committee)
  * [Collaborators](#collaborators)
  * [Release Keys](#release-keys)

## Support

Looking for help? Check out the
[instructions for getting support](.github/SUPPORT.md).

## Release Types

* **Current**: Under active development. Code for the Current release is in the
  branch for its major version number (for example,
  [v10.x](https://github.com/nodejs/node/tree/v10.x)). Node.js releases a new
  major version every 6 months, allowing for breaking changes. This happens in
  April and October every year. Releases appearing each October have a support
  life of 8 months. Releases appearing each April convert to LTS (see below)
  each October.
* **LTS**: Releases that receive Long-term Support, with a focus on stability
  and security. Every even-numbered major version will become an LTS release.
  LTS releases receive 12 months of _Active LTS_ support and a further 18 months
  of _Maintenance_. LTS release lines have alphabetically-ordered codenames,
  beginning with v4 Argon. There are no breaking changes or feature additions,
  except in some special circumstances.
* **Nightly**: Code from the Current branch built every 24-hours when there are
  changes. Use with caution.

Current and LTS releases follow [Semantic Versioning](https://semver.org). A
member of the Release Team [signs](#release-keys) each Current and LTS release.
For more information, see the
[Release README](https://github.com/nodejs/Release#readme).

### Download

Binaries, installers, and source tarballs are available at
<https://nodejs.org/en/download/>.

#### Current and LTS Releases
<https://nodejs.org/download/release/>

The [latest](https://nodejs.org/download/release/latest/) directory is an
alias for the latest Current release. The latest-_codename_ directory is an
alias for the latest release from an LTS line. For example, the
[latest-carbon](https://nodejs.org/download/release/latest-carbon/) directory
contains the latest Carbon (Node.js 8) release.

#### Nightly Releases
<https://nodejs.org/download/nightly/>

Each directory name and filename contains a date (in UTC time) and the commit
SHA at the HEAD of the release.

#### API Documentation

Documentation for the latest Current release is at <https://nodejs.org/api/>.
Version-specific documentation is available in each release directory in the
_docs_ subdirectory. Version-specific documentation is also at
<https://nodejs.org/download/docs/>.

### Verifying Binaries

Download directories contain a `SHASUMS256.txt` file with SHA checksums for the
files.

To download `SHASUMS256.txt` using `curl`:

```console
$ curl -O https://nodejs.org/dist/vx.y.z/SHASUMS256.txt
```

To check that a downloaded file matches the checksum, run
it through `sha256sum` with a command such as:

```console
$ grep node-vx.y.z.tar.gz SHASUMS256.txt | sha256sum -c -
```

For Current and LTS, the GPG detached signature of `SHASUMS256.txt` is in
`SHASUMS256.txt.sig`. You can use it with `gpg` to verify the integrity of
`SHASUM256.txt`. You will first need to import
[the GPG keys of individuals authorized to create releases](#release-keys). To
import the keys:

```console
$ gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
```

See the bottom of this README for a full script to import active release keys.

Next, download the `SHASUMS256.txt.sig` for the release:

```console
$ curl -O https://nodejs.org/dist/vx.y.z/SHASUMS256.txt.sig
```

Then use `gpg --verify SHASUMS256.txt.sig SHASUMS256.txt` to verify
the file's signature.

## Building Node.js

See [BUILDING.md](BUILDING.md) for instructions on how to build Node.js from
source and a list of supported platforms.

## Security

For information on reporting security vulnerabilities in Node.js, see
[SECURITY.md](./SECURITY.md).

## Contributing to Node.js

* [Contributing to the project][]
* [Working Groups][]
* [Strategic Initiatives][]

## Current Project Team Members

For information about the governance of the Node.js project, see
[GOVERNANCE.md](./GOVERNANCE.md).

### TSC (Technical Steering Committee)

* [addaleax](https://github.com/addaleax) -
**Anna Henningsen** &lt;anna@addaleax.net&gt; (she/her)
* [apapirovski](https://github.com/apapirovski) -
**Anatoli Papirovski** &lt;apapirovski@mac.com&gt; (he/him)
* [BethGriggs](https://github.com/BethGriggs) -
**Beth Griggs** &lt;Bethany.Griggs@uk.ibm.com&gt; (she/her)
* [ChALkeR](https://github.com/ChALkeR) -
**Сковорода Никита Андреевич** &lt;chalkerx@gmail.com&gt; (he/him)
* [cjihrig](https://github.com/cjihrig) -
**Colin Ihrig** &lt;cjihrig@gmail.com&gt; (he/him)
* [danbev](https://github.com/danbev) -
**Daniel Bevenius** &lt;daniel.bevenius@gmail.com&gt; (he/him)
* [fhinkel](https://github.com/fhinkel) -
**Franziska Hinkelmann** &lt;franziska.hinkelmann@gmail.com&gt; (she/her)
* [Fishrock123](https://github.com/Fishrock123) -
**Jeremiah Senkpiel** &lt;fishrock123@rocketmail.com&gt;
* [gabrielschulhof](https://github.com/gabrielschulhof) -
**Gabriel Schulhof** &lt;gabriel.schulhof@intel.com&gt;
* [gireeshpunathil](https://github.com/gireeshpunathil) -
**Gireesh Punathil** &lt;gpunathi@in.ibm.com&gt; (he/him)
* [jasnell](https://github.com/jasnell) -
**James M Snell** &lt;jasnell@gmail.com&gt; (he/him)
* [joyeecheung](https://github.com/joyeecheung) -
**Joyee Cheung** &lt;joyeec9h3@gmail.com&gt; (she/her)
* [mcollina](https://github.com/mcollina) -
**Matteo Collina** &lt;matteo.collina@gmail.com&gt; (he/him)
* [mhdawson](https://github.com/mhdawson) -
**Michael Dawson** &lt;michael_dawson@ca.ibm.com&gt; (he/him)
* [MylesBorins](https://github.com/MylesBorins) -
**Myles Borins** &lt;myles.borins@gmail.com&gt; (he/him)
* [sam-github](https://github.com/sam-github) -
**Sam Roberts** &lt;vieuxtech@gmail.com&gt;
* [targos](https://github.com/targos) -
**Michaël Zasso** &lt;targos@protonmail.com&gt; (he/him)
* [thefourtheye](https://github.com/thefourtheye) -
**Sakthipriyan Vairamani** &lt;thechargingvolcano@gmail.com&gt; (he/him)
* [tniessen](https://github.com/tniessen) -
**Tobias Nießen** &lt;tniessen@tnie.de&gt;
* [Trott](https://github.com/Trott) -
**Rich Trott** &lt;rtrott@gmail.com&gt; (he/him)

### TSC Emeriti

* [bnoordhuis](https://github.com/bnoordhuis) -
**Ben Noordhuis** &lt;info@bnoordhuis.nl&gt;
* [chrisdickinson](https://github.com/chrisdickinson) -
**Chris Dickinson** &lt;christopher.s.dickinson@gmail.com&gt;
* [evanlucas](https://github.com/evanlucas) -
**Evan Lucas** &lt;evanlucas@me.com&gt; (he/him)
* [gibfahn](https://github.com/gibfahn) -
**Gibson Fahnestock** &lt;gibfahn@gmail.com&gt; (he/him)
* [indutny](https://github.com/indutny) -
**Fedor Indutny** &lt;fedor.indutny@gmail.com&gt;
* [isaacs](https://github.com/isaacs) -
**Isaac Z. Schlueter** &lt;i@izs.me&gt;
* [joshgav](https://github.com/joshgav) -
**Josh Gavant** &lt;josh.gavant@outlook.com&gt;
* [mscdex](https://github.com/mscdex) -
**Brian White** &lt;mscdex@mscdex.net&gt;
* [nebrius](https://github.com/nebrius) -
**Bryan Hughes** &lt;bryan@nebri.us&gt;
* [ofrobots](https://github.com/ofrobots) -
**Ali Ijaz Sheikh** &lt;ofrobots@google.com&gt; (he/him)
* [orangemocha](https://github.com/orangemocha) -
**Alexis Campailla** &lt;orangemocha@nodejs.org&gt;
* [piscisaureus](https://github.com/piscisaureus) -
**Bert Belder** &lt;bertbelder@gmail.com&gt;
* [rvagg](https://github.com/rvagg) -
**Rod Vagg** &lt;r@va.gg&gt;
* [shigeki](https://github.com/shigeki) -
**Shigeki Ohtsu** &lt;ohtsu@ohtsu.org&gt; (he/him)
* [TimothyGu](https://github.com/TimothyGu) -
**Tiancheng "Timothy" Gu** &lt;timothygu99@gmail.com&gt; (he/him)
* [trevnorris](https://github.com/trevnorris) -
**Trevor Norris** &lt;trev.norris@gmail.com&gt;

### Collaborators

* [addaleax](https://github.com/addaleax) -
**Anna Henningsen** &lt;anna@addaleax.net&gt; (she/her)
* [ak239](https://github.com/ak239) -
**Aleksei Koziatinskii** &lt;ak239spb@gmail.com&gt;
* [AndreasMadsen](https://github.com/AndreasMadsen) -
**Andreas Madsen** &lt;amwebdk@gmail.com&gt; (he/him)
* [antsmartian](https://github.com/antsmartian) -
**Anto Aravinth** &lt;anto.aravinth.cse@gmail.com&gt; (he/him)
* [apapirovski](https://github.com/apapirovski) -
**Anatoli Papirovski** &lt;apapirovski@mac.com&gt; (he/him)
* [aqrln](https://github.com/aqrln) -
**Alexey Orlenko** &lt;eaglexrlnk@gmail.com&gt; (he/him)
* [bcoe](https://github.com/bcoe) -
**Ben Coe** &lt;bencoe@gmail.com&gt; (he/him)
* [bengl](https://github.com/bengl) -
**Bryan English** &lt;bryan@bryanenglish.com&gt; (he/him)
* [benjamingr](https://github.com/benjamingr) -
**Benjamin Gruenbaum** &lt;benjamingr@gmail.com&gt;
* [BethGriggs](https://github.com/BethGriggs) -
**Beth Griggs** &lt;Bethany.Griggs@uk.ibm.com&gt; (she/her)
* [bmeck](https://github.com/bmeck) -
**Bradley Farias** &lt;bradley.meck@gmail.com&gt;
* [bmeurer](https://github.com/bmeurer) -
**Benedikt Meurer** &lt;benedikt.meurer@gmail.com&gt;
* [bnoordhuis](https://github.com/bnoordhuis) -
**Ben Noordhuis** &lt;info@bnoordhuis.nl&gt;
* [boneskull](https://github.com/boneskull) -
**Christopher Hiller** &lt;boneskull@boneskull.com&gt; (he/him)
* [BridgeAR](https://github.com/BridgeAR) -
**Ruben Bridgewater** &lt;ruben@bridgewater.de&gt; (he/him)
* [bzoz](https://github.com/bzoz) -
**Bartosz Sosnowski** &lt;bartosz@janeasystems.com&gt;
* [calvinmetcalf](https://github.com/calvinmetcalf) -
**Calvin Metcalf** &lt;calvin.metcalf@gmail.com&gt;
* [cclauss](https://github.com/cclauss) -
**Christian Clauss** &lt;cclauss@me.com&gt; (he/him)
* [ChALkeR](https://github.com/ChALkeR) -
**Сковорода Никита Андреевич** &lt;chalkerx@gmail.com&gt; (he/him)
* [cjihrig](https://github.com/cjihrig) -
**Colin Ihrig** &lt;cjihrig@gmail.com&gt; (he/him)
* [claudiorodriguez](https://github.com/claudiorodriguez) -
**Claudio Rodriguez** &lt;cjrodr@yahoo.com&gt;
* [codebytere](https://github.com/codebytere) -
**Shelley Vohr** &lt;codebytere@gmail.com&gt; (she/her)
* [danbev](https://github.com/danbev) -
**Daniel Bevenius** &lt;daniel.bevenius@gmail.com&gt; (he/him)
* [davisjam](https://github.com/davisjam) -
**Jamie Davis** &lt;davisjam@vt.edu&gt; (he/him)
* [devnexen](https://github.com/devnexen) -
**David Carlier** &lt;devnexen@gmail.com&gt;
* [devsnek](https://github.com/devsnek) -
**Gus Caplan** &lt;me@gus.host&gt; (he/him)
* [digitalinfinity](https://github.com/digitalinfinity) -
**Hitesh Kanwathirtha** &lt;digitalinfinity@gmail.com&gt; (he/him)
* [edsadr](https://github.com/edsadr) -
**Adrian Estrada** &lt;edsadr@gmail.com&gt; (he/him)
* [eljefedelrodeodeljefe](https://github.com/eljefedelrodeodeljefe) -
**Robert Jefe Lindstaedt** &lt;robert.lindstaedt@gmail.com&gt;
* [eugeneo](https://github.com/eugeneo) -
**Eugene Ostroukhov** &lt;eostroukhov@google.com&gt;
* [evanlucas](https://github.com/evanlucas) -
**Evan Lucas** &lt;evanlucas@me.com&gt; (he/him)
* [fhinkel](https://github.com/fhinkel) -
**Franziska Hinkelmann** &lt;franziska.hinkelmann@gmail.com&gt; (she/her)
* [Fishrock123](https://github.com/Fishrock123) -
**Jeremiah Senkpiel** &lt;fishrock123@rocketmail.com&gt;
* [gabrielschulhof](https://github.com/gabrielschulhof) -
**Gabriel Schulhof** &lt;gabriel.schulhof@intel.com&gt;
* [gdams](https://github.com/gdams) -
**George Adams** &lt;george.adams@uk.ibm.com&gt; (he/him)
* [geek](https://github.com/geek) -
**Wyatt Preul** &lt;wpreul@gmail.com&gt;
* [gengjiawen](https://github.com/gengjiawen) -
**Jiawen Geng** &lt;technicalcute@gmail.com&gt;
* [GeoffreyBooth](https://github.com/geoffreybooth) -
**Geoffrey Booth** &lt;webmaster@geoffreybooth.com&gt; (he/him)
* [gibfahn](https://github.com/gibfahn) -
**Gibson Fahnestock** &lt;gibfahn@gmail.com&gt; (he/him)
* [gireeshpunathil](https://github.com/gireeshpunathil) -
**Gireesh Punathil** &lt;gpunathi@in.ibm.com&gt; (he/him)
* [guybedford](https://github.com/guybedford) -
**Guy Bedford** &lt;guybedford@gmail.com&gt; (he/him)
* [hashseed](https://github.com/hashseed) -
**Yang Guo** &lt;yangguo@chromium.org&gt; (he/him)
* [hiroppy](https://github.com/hiroppy) -
**Yuta Hiroto** &lt;hello@hiroppy.me&gt; (he/him)
* [iarna](https://github.com/iarna) -
**Rebecca Turner** &lt;me@re-becca.org&gt;
* [indutny](https://github.com/indutny) -
**Fedor Indutny** &lt;fedor.indutny@gmail.com&gt;
* [italoacasas](https://github.com/italoacasas) -
**Italo A. Casas** &lt;me@italoacasas.com&gt; (he/him)
* [JacksonTian](https://github.com/JacksonTian) -
**Jackson Tian** &lt;shyvo1987@gmail.com&gt;
* [jasnell](https://github.com/jasnell) -
**James M Snell** &lt;jasnell@gmail.com&gt; (he/him)
* [jbergstroem](https://github.com/jbergstroem) -
**Johan Bergström** &lt;bugs@bergstroem.nu&gt;
* [jdalton](https://github.com/jdalton) -
**John-David Dalton** &lt;john.david.dalton@gmail.com&gt;
* [jkrems](https://github.com/jkrems) -
**Jan Krems** &lt;jan.krems@gmail.com&gt; (he/him)
* [joaocgreis](https://github.com/joaocgreis) -
**João Reis** &lt;reis@janeasystems.com&gt;
* [joyeecheung](https://github.com/joyeecheung) -
**Joyee Cheung** &lt;joyeec9h3@gmail.com&gt; (she/her)
* [julianduque](https://github.com/julianduque) -
**Julian Duque** &lt;julianduquej@gmail.com&gt; (he/him)
* [JungMinu](https://github.com/JungMinu) -
**Minwoo Jung** &lt;nodecorelab@gmail.com&gt; (he/him)
* [kfarnung](https://github.com/kfarnung) -
**Kyle Farnung** &lt;kfarnung@microsoft.com&gt; (he/him)
* [lance](https://github.com/lance) -
**Lance Ball** &lt;lball@redhat.com&gt; (he/him)
* [legendecas](https://github.com/legendecas) -
**Chengzhong Wu** &lt;legendecas@gmail.com&gt; (he/him)
* [Leko](https://github.com/Leko) -
**Shingo Inoue** &lt;leko.noor@gmail.com&gt; (he/him)
* [lpinca](https://github.com/lpinca) -
**Luigi Pinca** &lt;luigipinca@gmail.com&gt; (he/him)
* [lundibundi](https://github.com/lundibundi) -
**Denys Otrishko** &lt;shishugi@gmail.com&gt; (he/him)
* [maclover7](https://github.com/maclover7) -
**Jon Moss** &lt;me@jonathanmoss.me&gt; (he/him)
* [mafintosh](https://github.com/mafintosh)
**Mathias Buus** &lt;mathiasbuus@gmail.com&gt; (he/him)
* [mcollina](https://github.com/mcollina) -
**Matteo Collina** &lt;matteo.collina@gmail.com&gt; (he/him)
* [mhdawson](https://github.com/mhdawson) -
**Michael Dawson** &lt;michael_dawson@ca.ibm.com&gt; (he/him)
* [misterdjules](https://github.com/misterdjules) -
**Julien Gilli** &lt;jgilli@nodejs.org&gt;
* [mmarchini](https://github.com/mmarchini) -
**Matheus Marchini** &lt;mat@mmarchini.me&gt;
* [MoonBall](https://github.com/MoonBall) -
**Chen Gang** &lt;gangc.cxy@foxmail.com&gt;
* [mscdex](https://github.com/mscdex) -
**Brian White** &lt;mscdex@mscdex.net&gt;
* [MylesBorins](https://github.com/MylesBorins) -
**Myles Borins** &lt;myles.borins@gmail.com&gt; (he/him)
* [not-an-aardvark](https://github.com/not-an-aardvark) -
**Teddy Katz** &lt;teddy.katz@gmail.com&gt; (he/him)
* [ofrobots](https://github.com/ofrobots) -
**Ali Ijaz Sheikh** &lt;ofrobots@google.com&gt; (he/him)
* [oyyd](https://github.com/oyyd) -
**Ouyang Yadong** &lt;oyydoibh@gmail.com&gt; (he/him)
* [princejwesley](https://github.com/princejwesley) -
**Prince John Wesley** &lt;princejohnwesley@gmail.com&gt;
* [psmarshall](https://github.com/psmarshall) -
**Peter Marshall** &lt;petermarshall@chromium.org&gt; (he/him)
* [Qard](https://github.com/Qard) -
**Stephen Belanger** &lt;admin@stephenbelanger.com&gt; (he/him)
* [refack](https://github.com/refack) -
**Refael Ackermann (רפאל פלחי)** &lt;refack@gmail.com&gt; (he/him/הוא/אתה)
* [richardlau](https://github.com/richardlau) -
**Richard Lau** &lt;riclau@uk.ibm.com&gt;
* [ronkorving](https://github.com/ronkorving) -
**Ron Korving** &lt;ron@ronkorving.nl&gt;
* [rubys](https://github.com/rubys) -
**Sam Ruby** &lt;rubys@intertwingly.net&gt;
* [rvagg](https://github.com/rvagg) -
**Rod Vagg** &lt;rod@vagg.org&gt;
* [ryzokuken](https://github.com/ryzokuken) -
**Ujjwal Sharma** &lt;usharma1998@gmail.com&gt; (he/him)
* [saghul](https://github.com/saghul) -
**Saúl Ibarra Corretgé** &lt;saghul@gmail.com&gt;
* [sam-github](https://github.com/sam-github) -
**Sam Roberts** &lt;vieuxtech@gmail.com&gt;
* [santigimeno](https://github.com/santigimeno) -
**Santiago Gimeno** &lt;santiago.gimeno@gmail.com&gt;
* [sebdeckers](https://github.com/sebdeckers) -
**Sebastiaan Deckers** &lt;sebdeckers83@gmail.com&gt;
* [seishun](https://github.com/seishun) -
**Nikolai Vavilov** &lt;vvnicholas@gmail.com&gt;
* [shigeki](https://github.com/shigeki) -
**Shigeki Ohtsu** &lt;ohtsu@ohtsu.org&gt; (he/him)
* [shisama](https://github.com/shisama) -
**Masashi Hirano** &lt;shisama07@gmail.com&gt; (he/him)
* [silverwind](https://github.com/silverwind) -
**Roman Reiss** &lt;me@silverwind.io&gt;
* [srl295](https://github.com/srl295) -
**Steven R Loomis** &lt;srloomis@us.ibm.com&gt;
* [starkwang](https://github.com/starkwang) -
**Weijia Wang** &lt;starkwang@126.com&gt;
* [targos](https://github.com/targos) -
**Michaël Zasso** &lt;targos@protonmail.com&gt; (he/him)
* [thefourtheye](https://github.com/thefourtheye) -
**Sakthipriyan Vairamani** &lt;thechargingvolcano@gmail.com&gt; (he/him)
* [thekemkid](https://github.com/thekemkid) -
**Glen Keane** &lt;glenkeane.94@gmail.com&gt; (he/him)
* [TimothyGu](https://github.com/TimothyGu) -
**Tiancheng "Timothy" Gu** &lt;timothygu99@gmail.com&gt; (he/him)
* [tniessen](https://github.com/tniessen) -
**Tobias Nießen** &lt;tniessen@tnie.de&gt;
* [trevnorris](https://github.com/trevnorris) -
**Trevor Norris** &lt;trev.norris@gmail.com&gt;
* [trivikr](https://github.com/trivikr) -
**Trivikram Kamat** &lt;trivikr.dev@gmail.com&gt;
* [Trott](https://github.com/Trott) -
**Rich Trott** &lt;rtrott@gmail.com&gt; (he/him)
* [vdeturckheim](https://github.com/vdeturckheim) -
**Vladimir de Turckheim** &lt;vlad2t@hotmail.com&gt; (he/him)
* [vkurchatkin](https://github.com/vkurchatkin) -
**Vladimir Kurchatkin** &lt;vladimir.kurchatkin@gmail.com&gt;
* [watilde](https://github.com/watilde) -
**Daijiro Wachi** &lt;daijiro.wachi@gmail.com&gt; (he/him)
* [watson](https://github.com/watson) -
**Thomas Watson** &lt;w@tson.dk&gt;
* [XadillaX](https://github.com/XadillaX) -
**Khaidi Chu** &lt;i@2333.moe&gt; (he/him)
* [yhwang](https://github.com/yhwang) -
**Yihong Wang** &lt;yh.wang@ibm.com&gt;
* [yorkie](https://github.com/yorkie) -
**Yorkie Liu** &lt;yorkiefixer@gmail.com&gt;
* [yosuke-furukawa](https://github.com/yosuke-furukawa) -
**Yosuke Furukawa** &lt;yosuke.furukawa@gmail.com&gt;
* [ZYSzys](https://github.com/ZYSzys) -
**Yongsheng Zhang** &lt;zyszys98@gmail.com&gt; (he/him)

### Collaborator Emeriti

* [andrasq](https://github.com/andrasq) -
**Andras** &lt;andras@kinvey.com&gt;
* [AnnaMag](https://github.com/AnnaMag) -
**Anna M. Kedzierska** &lt;anna.m.kedzierska@gmail.com&gt;
* [brendanashworth](https://github.com/brendanashworth) -
**Brendan Ashworth** &lt;brendan.ashworth@me.com&gt;
* [estliberitas](https://github.com/estliberitas) -
**Alexander Makarenko** &lt;estliberitas@gmail.com&gt;
* [chrisdickinson](https://github.com/chrisdickinson) -
**Chris Dickinson** &lt;christopher.s.dickinson@gmail.com&gt;
* [DavidCai1993](https://github.com/DavidCai1993) -
**David Cai** &lt;davidcai1993@yahoo.com&gt; (he/him)
* [firedfox](https://github.com/firedfox) -
**Daniel Wang** &lt;wangyang0123@gmail.com&gt;
* [imran-iq](https://github.com/imran-iq) -
**Imran Iqbal** &lt;imran@imraniqbal.org&gt;
* [imyller](https://github.com/imyller) -
**Ilkka Myller** &lt;ilkka.myller@nodefield.com&gt;
* [isaacs](https://github.com/isaacs) -
**Isaac Z. Schlueter** &lt;i@izs.me&gt;
* [jasongin](https://github.com/jasongin) -
**Jason Ginchereau** &lt;jasongin@microsoft.com&gt;
* [jhamhader](https://github.com/jhamhader) -
**Yuval Brik** &lt;yuval@brik.org.il&gt;
* [joshgav](https://github.com/joshgav) -
**Josh Gavant** &lt;josh.gavant@outlook.com&gt;
* [kunalspathak](https://github.com/kunalspathak) -
**Kunal Pathak** &lt;kunal.pathak@microsoft.com&gt;
* [lucamaraschi](https://github.com/lucamaraschi) -
**Luca Maraschi** &lt;luca.maraschi@gmail.com&gt; (he/him)
* [lxe](https://github.com/lxe) -
**Aleksey Smolenchuk** &lt;lxe@lxe.co&gt;
* [matthewloring](https://github.com/matthewloring) -
**Matthew Loring** &lt;mattloring@google.com&gt;
* [micnic](https://github.com/micnic) -
**Nicu Micleușanu** &lt;micnic90@gmail.com&gt; (he/him)
* [mikeal](https://github.com/mikeal) -
**Mikeal Rogers** &lt;mikeal.rogers@gmail.com&gt;
* [monsanto](https://github.com/monsanto) -
**Christopher Monsanto** &lt;chris@monsan.to&gt;
* [Olegas](https://github.com/Olegas) -
**Oleg Elifantiev** &lt;oleg@elifantiev.ru&gt;
* [orangemocha](https://github.com/orangemocha) -
**Alexis Campailla** &lt;orangemocha@nodejs.org&gt;
* [othiym23](https://github.com/othiym23) -
**Forrest L Norvell** &lt;ogd@aoaioxxysz.net&gt; (he/him)
* [petkaantonov](https://github.com/petkaantonov) -
**Petka Antonov** &lt;petka_antonov@hotmail.com&gt;
* [phillipj](https://github.com/phillipj) -
**Phillip Johnsen** &lt;johphi@gmail.com&gt;
* [piscisaureus](https://github.com/piscisaureus) -
**Bert Belder** &lt;bertbelder@gmail.com&gt;
* [pmq20](https://github.com/pmq20) -
**Minqi Pan** &lt;pmq2001@gmail.com&gt;
* [rlidwka](https://github.com/rlidwka) -
**Alex Kocharin** &lt;alex@kocharin.ru&gt;
* [rmg](https://github.com/rmg) -
**Ryan Graham** &lt;r.m.graham@gmail.com&gt;
* [robertkowalski](https://github.com/robertkowalski) -
**Robert Kowalski** &lt;rok@kowalski.gd&gt;
* [romankl](https://github.com/romankl) -
**Roman Klauke** &lt;romaaan.git@gmail.com&gt;
* [RReverser](https://github.com/RReverser) -
**Ingvar Stepanyan** &lt;me@rreverser.com&gt;
* [stefanmb](https://github.com/stefanmb) -
**Stefan Budeanu** &lt;stefan@budeanu.com&gt;
* [tellnes](https://github.com/tellnes) -
**Christian Tellnes** &lt;christian@tellnes.no&gt;
* [thlorenz](https://github.com/thlorenz) -
**Thorsten Lorenz** &lt;thlorenz@gmx.de&gt;
* [tunniclm](https://github.com/tunniclm) -
**Mike Tunnicliffe** &lt;m.j.tunnicliffe@gmail.com&gt;
* [vsemozhetbyt](https://github.com/vsemozhetbyt) -
**Vse Mozhet Byt** &lt;vsemozhetbyt@gmail.com&gt; (he/him)
* [whitlockjc](https://github.com/whitlockjc) -
**Jeremy Whitlock** &lt;jwhitlock@apache.org&gt;

Collaborators follow the [COLLABORATOR_GUIDE.md](./COLLABORATOR_GUIDE.md) in
maintaining the Node.js project.

### Release Keys

GPG keys used to sign Node.js releases:

* **Beth Griggs** &lt;bethany.griggs@uk.ibm.com&gt;
`4ED778F539E3634C779C87C6D7062848A1AB005C`
* **Colin Ihrig** &lt;cjihrig@gmail.com&gt;
`94AE36675C464D64BAFA68DD7434390BDBE9B9C5`
* **Evan Lucas** &lt;evanlucas@me.com&gt;
`B9AE9905FFD7803F25714661B63B535A4C206CA9`
* **Gibson Fahnestock** &lt;gibfahn@gmail.com&gt;
`77984A986EBC2AA786BC0F66B01FBB92821C587A`
* **James M Snell** &lt;jasnell@keybase.io&gt;
`71DCFD284A79C3B38668286BC97EC7A07EDE3FC1`
* **Jeremiah Senkpiel** &lt;fishrock@keybase.io&gt;
`FD3A5288F042B6850C66B31F09FE44734EB7990E`
* **Michaël Zasso** &lt;targos@protonmail.com&gt;
`8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600`
* **Myles Borins** &lt;myles.borins@gmail.com&gt;
`C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8`
* **Rod Vagg** &lt;rod@vagg.org&gt;
`DD8F2338BAE7501E3DD5AC78C273792F7D83545D`
* **Ruben Bridgewater** &lt;ruben@bridgewater.de&gt;
`A48C2BEE680E841632CD4E44F07496B3EB3C1762`
* **Shelley Vohr** &lt;shelley.vohr@gmail.com&gt;
`B9E2F5981AA6E0CD28160D9FF13993A75599653C`

To import the full set of trusted release keys:

```shell
gpg --keyserver pool.sks-keyservers.net --recv-keys 4ED778F539E3634C779C87C6D7062848A1AB005C
gpg --keyserver pool.sks-keyservers.net --recv-keys B9E2F5981AA6E0CD28160D9FF13993A75599653C
gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5
gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9
gpg --keyserver pool.sks-keyservers.net --recv-keys 77984A986EBC2AA786BC0F66B01FBB92821C587A
gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E
gpg --keyserver pool.sks-keyservers.net --recv-keys 8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600
gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8
gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
gpg --keyserver pool.sks-keyservers.net --recv-keys A48C2BEE680E841632CD4E44F07496B3EB3C1762
```

See the section above on [Verifying Binaries](#verifying-binaries) for how to
use these keys to verify a downloaded file.

Other keys used to sign some previous releases:

* **Chris Dickinson** &lt;christopher.s.dickinson@gmail.com&gt;
`9554F04D7259F04124DE6B476D5A82AC7E37093B`
* **Isaac Z. Schlueter** &lt;i@izs.me&gt;
`93C7E9E91B49E432C2F75674B0A78B0A6C481CF6`
* **Italo A. Casas** &lt;me@italoacasas.com&gt;
`56730D5401028683275BD23C23EFEFE93C4CFFFE`
* **Julien Gilli** &lt;jgilli@fastmail.fm&gt;
`114F43EE0176B71C7BC219DD50A3051F888C628D`
* **Timothy J Fontaine** &lt;tjfontaine@gmail.com&gt;
`7937DFD2AB06298B2293C3187D33FF9D0246406D`

[Code of Conduct]: https://github.com/nodejs/admin/blob/master/CODE_OF_CONDUCT.md
[Contributing to the project]: CONTRIBUTING.md
[Node.js Website]: https://nodejs.org/
[OpenJS Foundation]: http://openjs.foundation/
[Working Groups]: https://github.com/nodejs/TSC/blob/master/WORKING_GROUPS.md
[Strategic Initiatives]: https://github.com/nodejs/TSC/blob/master/Strategic-Initiatives.md

<hr />

<img src="https://raw.githubusercontent.com/hexojs/logo/master/hexo-logo-avatar.png" alt="Hexo logo" width="100" height="100" align="right" />

# Hexo

> A fast, simple & powerful blog framework, powered by [Node.js](https://nodejs.org).

[Website](https://hexo.io) |
[Documentation](https://hexo.io/docs/) |
[Installation Guide](https://hexo.io/docs/#Installation) |
[Contribution Guide](https://hexo.io/docs/contributing) |
[Code of Conduct](CODE_OF_CONDUCT.md) |
[API](https://hexo.io/api/) |
[Twitter](https://twitter.com/hexojs)

[![NPM version](https://badge.fury.io/js/hexo.svg)](https://www.npmjs.com/package/hexo)
![Required Node version](https://img.shields.io/node/v/hexo)
[![Build Status](https://travis-ci.com/hexojs/hexo.svg?branch=master)](https://travis-ci.com/hexojs/hexo)
[![Build status](https://ci.appveyor.com/api/projects/status/github/hexojs/hexo?branch=master&svg=true)](https://ci.appveyor.com/project/tommy351/hexo/branch/master)
[![dependencies Status](https://david-dm.org/hexojs/hexo/status.svg)](https://david-dm.org/hexojs/hexo)
[![devDependencies Status](https://david-dm.org/hexojs/hexo/dev-status.svg)](https://david-dm.org/hexojs/hexo?type=dev)
[![Coverage Status](https://coveralls.io/repos/hexojs/hexo/badge.svg?branch=master)](https://coveralls.io/r/hexojs/hexo?branch=master)
[![Gitter](https://badges.gitter.im/hexojs/hexo.svg)](https://gitter.im/hexojs/hexo)
[![Discord Chat](https://img.shields.io/badge/chat-on%20discord-7289da.svg)](https://discord.gg/teM2Anj)
[![Telegram Chat](https://img.shields.io/badge/chat-on%20telegram-32afed.svg)](https://t.me/hexojs)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fhexojs%2Fhexo.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fhexojs%2Fhexo?ref=badge_shield)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

## Features

- Blazing fast generating
- Support for GitHub Flavored Markdown and most Octopress plugins
- One-command deploy to GitHub Pages, Heroku, etc.
- Powerful API for limitless extensibility
- Hundreds of [themes](https://hexo.io/themes/) & [plugins](https://hexo.io/plugins/)

## Quick Start

**Install Hexo**

``` bash
$ npm install hexo-cli -g
```

**Setup your blog**

``` bash
$ hexo init blog
$ cd blog
```

**Start the server**

``` bash
$ hexo server
```

**Create a new post**

``` bash
$ hexo new "Hello Hexo"
```

**Generate static files**

``` bash
$ hexo generate
```

## More Information

- Read the [documentation](https://hexo.io/)
- Visit the [Awesome Hexo](https://github.com/hexojs/awesome-hexo) list
- Find solutions in [troubleshooting](https://hexo.io/docs/troubleshooting.html)
- Join discussion on [Google Group](https://groups.google.com/group/hexo), [Discord](https://discord.gg/teM2Anj), [Gitter](https://gitter.im/hexojs/hexo) or [Telegram](https://t.me/hexojs)
- See the [plugin list](https://hexo.io/plugins/) and the [theme list](https://hexo.io/themes/) on wiki
- Follow [@hexojs](https://twitter.com/hexojs) for latest news

## Contributing

We welcome you to join the development of Hexo. Please see [contributing document](https://hexo.io/docs/contributing). 🤗

Also, we welcome PR or issue to [official-plugins](https://github.com/hexojs).

## Contributors

[![](https://opencollective.com/Hexo/contributors.svg?width=890)](https://github.com/hexojs/hexo/graphs/contributors)

## Backers

[![Backers](https://opencollective.com/hexo/tiers/backers.svg?avatarHeight=36&width=600)](https://opencollective.com/hexo)

## Sponsors

<a href="https://www.jetbrains.com/"><img src="/.github/jetbrains-variant-4.svg" alt="JetBrains" width="200"/></a>

<a href="https://www.cmscritic.com/"><img src="/.github/CMS-Critic_logo-3.png" alt="CMS Critic" width="200"/></a>

<a href="https://getform.io/"><img src="/.github/getform-logo.svg" alt="Getform" width="200"/></a>

## License

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fhexojs%2Fhexo.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fhexojs%2Fhexo?ref=badge_large)

<hr />

<div align="right">
  Language:
  🇺🇸
  <a title="Chinese" href="docs/zh-CN/README.md">🇨🇳</a>
  <a title="Russian" href="docs/ru/README.md">🇷🇺</a>
</div>

# <div align="center"><a title="NexT website repository" href="https://github.com/theme-next/theme-next.org"><img align="center" width="56" height="56" src="https://raw.githubusercontent.com/theme-next/hexo-theme-next/master/source/images/logo.svg?sanitize=true"></a> e x T</div>

<p align="center">
  «NexT» is a high quality elegant <a href="https://hexo.io">Hexo</a> theme. It is crafted from scratch with love.
<br>
<br>
  <a href="https://github.com/theme-next/hexo-theme-next/releases"><img src="https://img.shields.io/github/package-json/v/theme-next/hexo-theme-next?style=flat-square"></a>
  <a href="https://nodejs.org"><img src="https://img.shields.io/badge/node-%3E=10.9.0-green?style=flat-square"></a>
  <a href="https://hexo.io"><img src="https://img.shields.io/badge/hexo-%3E=3.5.0-blue?style=flat-square&logo=hexo"></a>
  <a href="https://github.com/theme-next/hexo-theme-next/blob/master/LICENSE.md"><img src="https://img.shields.io/badge/license-%20AGPL-orange?style=flat-square&logo=gnu"></a>
<br>
  <a href="https://bestpractices.coreinfrastructure.org/projects/2625"><img src="https://img.shields.io/cii/level/2625?style=flat-square" title="Core Infrastructure Initiative Best Practices"></a>
  <a href="https://travis-ci.org/theme-next/hexo-theme-next?branch=master"><img src="https://img.shields.io/travis/theme-next/hexo-theme-next/master?style=flat-square&logo=travis%20ci" title="Travis CI [Linux]"></a>
  <a href="https://app.codacy.com/manual/theme-next/hexo-theme-next/dashboard"><img src="https://img.shields.io/codacy/grade/72f7fe7609c2438a92069f448e5a341a/master?style=flat-square&logo=codacy" title="Project Grade"></a>
  <img src="https://img.shields.io/snyk/vulnerabilities/github/theme-next/hexo-theme-next?style=flat-square" title="Vulnerabilities">
<br>
  <img src="https://user-images.githubusercontent.com/16272760/63487983-da41b080-c4df-11e9-951c-64883a8a5e9b.png">
</p>

## Live Preview

<p align="center">
  💟 <a href="https://muse.theme-next.org">Muse</a> | 🔯 <a href="https://mist.theme-next.org">Mist</a> | ♓️ <a href="https://pisces.theme-next.org">Pisces</a> | ♊️ <a href="https://theme-next.org">Gemini</a>
<br>
<br>
  More «NexT» examples <a href="https://github.com/theme-next/awesome-next#live-preview">here</a>.
</p>

## Installation

The simplest way to install is to clone the entire repository:

```sh
$ cd hexo
$ git clone https://github.com/theme-next/hexo-theme-next themes/next
```

Or you can see [detailed installation instructions][docs-installation-url] if you want any other variant.

## Plugins

In NexT config now you can find dependencies on each module which was moved to external repositories which can be found by [main organization link][official-plugins-url].

For example, if you want to enable `pjax` on your site, go to NexT config and see:

```yml
# Easily enable fast Ajax navigation on your website.
# Dependencies: https://github.com/theme-next/theme-next-pjax
pjax: false
```

Then turn on `pjax` and go to «Dependencies» link with installation instructions of this module.

### Configure CDN

If you use CDN for any plugins, you need to replace your CDN link.

For example, if you want to use `mediumzoom` and you configured a CDN link, go to NexT config and see:

```yml
vendors:
  # ...
  # Some contents...
  # ...
  mediumzoom: # Set or update mediumzoom CDN URL.
```

Instead of defining [main organization link][official-plugins-url] for updates.

## Update

You can update to latest master branch by the following command:

```sh
$ cd themes/next
$ git pull
```

And if you see any error message during update (something like **«Commit your changes or stash them before you can merge»**), recommended to learn [Hexo data files][docs-data-files-url] feature.\
However, you can bypass update errors by using the `Commit`, `Stash` or `Reset` commands for local changes. See [here](https://stackoverflow.com/a/15745424/5861495) how to do it.

**If you want to update from v5.1.x to the latest version, read [this][docs-update-5-1-x-url].**

## Feedback

* Follow us with [Telegram Channel][t-news-url] for latest news.
* Join our [Telegram][t-chat-url] / [Gitter][gitter-url] / [Riot][riot-url] chats.
* [Add or improve translation][i18n-url] in few seconds.
* Visit the [Awesome NexT][awesome-next-url] list.
* Report a bug in [GitHub Issues][issues-bug-url].
* Request a new feature on [GitHub][issues-feat-url].
* Vote for [popular feature requests][feat-req-vote-url].

## Contributing

We welcome you to join the development of NexT. Please see [contributing document][contributing-document-url]. 🤗

Also, we welcome Issue or PR to [official-plugins][official-plugins-url].

## Contributors

[![][contributors-image]][contributors-url]

## Thanks

<p align="center">
  «NexT» send special thanks to these great services that sponsor our core infrastructure:
<br>
<br>
  <a href="https://github.com"><img align="center" width="100" src="https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png"></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://www.netlify.com"><img align="center" width="150" src="https://cdn.netlify.com/15ecf59b59c9d04b88097c6b5d2c7e8a7d1302d0/1b6d6/img/press/logos/full-logo-light.svg"></a>
<br>
<br>
  <sub>GitHub allows us to host the Git repository, Netlify allows us to distribute the documentation.</sub>
<br>
<br>
  <a href="https://crowdin.com"><img align="center" width="180" src="https://support.crowdin.com/assets/logos/crowdin-logo1-small.png"></a>
<br>
<br>
  <sub>Crowdin allows us to translate conveniently the documentation.</sub>
<br>
<br>
  <a href="https://codacy.com"><img align="center" width="155" src="https://user-images.githubusercontent.com/16944225/55026017-623f8f00-5002-11e9-88bf-0d6a5884c6c2.png"></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://travis-ci.com"><img align="center" width="140" src="https://raw.githubusercontent.com/travis-ci/travis-web/master/public/images/logos/TravisCI-Full-Color.png"></a>
<br>
<br>
  <sub>Codacy allows us to monitor code quality, Travis CI allows us to run the test suite.</sub>
</p>

[docs-installation-url]: https://github.com/theme-next/hexo-theme-next/blob/master/docs/INSTALLATION.md
[docs-data-files-url]: https://github.com/theme-next/hexo-theme-next/blob/master/docs/DATA-FILES.md
[docs-update-5-1-x-url]: https://github.com/theme-next/hexo-theme-next/blob/master/docs/UPDATE-FROM-5.1.X.md

[t-news-url]: https://t.me/theme_next_news
[t-chat-url]: https://t.me/theme_next
[gitter-url]: https://gitter.im/theme-next
[riot-url]: https://riot.im/app/#/room/#theme-next:matrix.org
[i18n-url]: https://i18n.theme-next.org

[awesome-next-url]: https://github.com/theme-next/awesome-next
[issues-bug-url]: https://github.com/theme-next/hexo-theme-next/issues/new?assignees=&labels=Bug&template=bug-report.md
[issues-feat-url]: https://github.com/theme-next/hexo-theme-next/issues/new?assignees=&labels=Feature+Request&template=feature-request.md
[feat-req-vote-url]: https://github.com/theme-next/hexo-theme-next/issues?q=is%3Aopen+is%3Aissue+label%3A%22Feature+Request%22

[contributing-document-url]: https://github.com/theme-next/hexo-theme-next/blob/master/.github/CONTRIBUTING.md
[official-plugins-url]: https://github.com/theme-next
[contributors-image]: https://opencollective.com/theme-next/contributors.svg?width=890
[contributors-url]: https://github.com/theme-next/hexo-theme-next/graphs/contributors

