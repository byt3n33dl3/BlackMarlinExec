[![Version](https://img.shields.io/badge/BME-2.9.8-brightgreen.svg?maxAge=259200)](https://www.nuget.org/packages/BlackMarlinExec/)
![Downloads](https://img.shields.io/nuget/dt/SharpHoundCommon)
[![Build](https://img.shields.io/badge/Best_OS-Linux-orange.svg)]()
[![License](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg)](https://github.com/pxcs/BlackMarlinExec/LICENSES)
[![Documentation](https://img.shields.io/static/v1?label=&message=documentation&color=blue)](https://github.com/pxcs/BlackMarlinExec/)

#### Black Marlin | Swordfish attacks | Enumeration tool | NTA tool | [BME](https://github.com/pxcs/BlackMarlinExec/) |

<a href="https://github.com/pxcs/BlackMarlinExec/"><p align="center">
<img width="300" height="300" src="/images/swordfish.png">
</p></a><br>

About **Active Directory** BlackMarlinExec, find the right attack path for pentesting and security researchs, it's ability to use graph theory to `reveal` the hidden and often unintended relationships within an online environments.
<br>
## About BlackMarlinExec
BlackMarlinExec uses graph and analysis theory to reveal the hidden and unintended relationships within an Active Directory or Active Environment. CS can use BlackMarlinExec to easily identify highly complex attack paths that would otherwise be impossible to `quickly` identify. It also has it's own attack path management that continuously maps and quantifies Active Directory attack paths. CS can see thousand, even `millions` of attack paths within your existing architecture.

## BlackMarlinExec [Kerberos](https://www.youtube.com/watch?v=-3MxoxdzFNI&t=353s&ab_channel=Conda) Attack Performance
BlackMarlinExec incorporates a specialized [Kerberos](https://github.com/pxcs/KerberossianCracker) attack module, empowering CS to effectively test and exploit weaknesses within the Kerberos authentication protocol. This module is designed to enhance the enumeration and `analysis` capabilities by focusing on potential vulnerabilities in Kerberos implementations.

#### Ticket Harvesting by:

- AS-REP Roasting by automates the extraction of AS-REP responses for accounts that do not require pre-authentication.
- And kerberoasting to identifies and extracts service tickets (TGS) for services that leverage Kerberos.

By integrating advanced Kerberos attack techniques with [BME](https://github.com/pxcs/BlackMarlinExec/) powerful enumeration and network traffic analysis capabilities, CS would gain a holistic view of the network's security posture.<br>

<a href="https://github.com/pxcs/KerberossianCracker"><p align="center">
<img width="320" height="300" src="/images/qerberus.png">
</p></a><hr>

## Small Demonstration for [Roasting](https://github.com/pxcs/BlackMarlinExec/tree/main/bma/ABAMB/tunnel_barracuda)
During an enumeration attack, CS verify records stored in a `storage` using brute-force methods. These CS occur on `storage` that interact with web server databases after a user submits a form. The two most commonly targeted web app pages in enumeration attacks are login pages and `password` reset [pages.](https://www.techtarget.com/searchsecurity/tip/What-enumeration-attacks-are-and-how-to-prevent-them)

## Intro About [Barracuda](https://github.com/pxcs/BlackMarlinExec/blob/main/bma/ABAMB/README.md) Attack

#### TCP Killer
[Barracuda](https://github.com/pxcs/BlackMarlinExec/blob/main/bma/ABAMB/) is a utility to kill all TCP connections on a network. It works by intercepting network traffic, and forging RST packets of existing connections to cause hangups. Works for both IPv4 connections and IPv6. Barracuda ( TCPkiller ) is a sneaky way to kill network connections. Any targeted system will appear to work when examined through typical diagnostics - DNS will resolve, ICMP's will go through, and the network card will be able to connect ( slow ) to the network-but no TCP connections will be sustained.

<a href="https://github.com/pxcs/KerberossianCracker"><p align="center">
<img width="200" height="200" src="/images/barracuda.png">
</p></a>

## Main Features:
 - Shows a list of processes, and tcp ports they are listening to
 - The list can by filtered by port number
 - You can select a process, and terminate it
 
#### There are many tools that implement this functionality. This tool will additionally:
 - Resolve the application name of every processes ( if `jps` is available )
 - For IANA registered ports you can hover over the port number, and it will show additional information
 - On windows, will show the names of services running as children of `ABAMB.exe`
<br>

Shuts down a TCP connection on Linux, macOS, and Windows. Local and remote endpoint arguments can be copied from the output of `netstat_lanW.`

The functionality offered by *TCP_killer* is intended to mimic [TCPView](https://technet.microsoft.com/en-us/sysinternals/tcpview.aspx)'s "Close Connection" functionality and [TCPdrop](http://man.openbsd.org/tcpdrop.8)'s functionality on Linux and macOS.

## Basic Usage


  ```powershell
BME_barracuda.py [-pS] <local endpoint> <remote endpoint>
[x] Initialized DNS Poisoning on eth0 in quiet mode. Press Ctrl-C to exit.
...
```

  ```powershell
BME_barracuda.py -i eth0
[*] Initialized TCPkiller on eth0 in quiet mode, targeting all. Press Ctrl-C to exit.
...
```

### Options:
 - ```-a, --allow``` find source or destination
 - ```-t, --target``` allow all other connections
 - ```-ts, --target-source``` but only if it's the source
 - ```-td, --target-destination``` actively target this ip address
 - ```-o, --allow-port``` checking any connections involving
 - ```-p, --target-port``` actively target any connections
 - ```-pS, --target-source-port``` finding port sources
 - ```-pd, --target-destination-port``` finding port destination
 - ```-r, --randomize [half,all]``` target SOME of the matching
 - ```-i, --interface``` specify interface
 - ```-s, --silent``` silences all terminal
 - ```-v, --verbose``` verbose output
 - ```-h, --help``` prints usage
 - ```-i, --tcp && eth0``` net

#### Arguments:

    -pS ( Show poisoning output )
    <local endpoint>   Connection's local IP address and port
    <remote endpoint>  Connection's remote IP address and port

#### Examples:

    BME_barracuda.py 10.31.33.7:50246 93.184.216.34:443
    BME_barracuda.py 2001:db8:85a3::8a2e:370:7334.93 2606:2800:220:1:248:1893:25c8:1946.80
    BME_barracuda.py -verbose [2001:4860:4860::8888]:46820 [2607:f8b0:4005:807::200e]:80

### Full Example
```
kali@kali:~$ # Create a server to listen on TCP port 12345
kali@kali:~$ nc -d -l -p 4444 &
[1] 135578

kali@kali:~$ # Connect to the local server on TCP port 12345
kali@kali:~$ nc -v -d localhost 4444 &
[2] 135579
Connection to localhost 4444 port [tcp/*] succeeded!

kali@kali:~$ # Find the connection endpoints
kali@kali:~$ netstat -lanW | grep 12345.*ESTABLISHED
tcp        0      0 127.0.0.1:33994         127.0.0.1:12345         ESTABLISHED
tcp        0      0 127.0.0.1:12345         127.0.0.1:33994         ESTABLISHED

kali@kali:~$ # Kill the connection by copying and pasting the output of netstat
kali@kali:~$ python BME_barracuda.py 127.0.0.1:33994         127.0.0.1:4444
TCP connection was successfully shutdown.
[1]-  Done                    nc -d -l -p 4444
[2]+  Done                    nc -v -d localhost 4444
```

## [LDAP](https://www.youtube.com/watch?v=Xjpi8xYqPcY&pp=ygUUa2VyYmVyb3MgdnMga2VyYmVyb3M%3D) & Kerberos Protocol Potential Attacks
Using [BlackMarlinExec](https://github.com/pxcs/BlackMarlinExec/) to get benefits of integration. Firstly find a significant risk. A CS would try to "steal" user credentials through malware or AD Attacks using [BME](https://github.com/pxcs/BlackMarlinExec/), enabling them to `obtain` a Ticket Granting Ticket (TGT) and access network services. Man-in-the-Middle (MITM) attacks pose another threat, where an attacker intercepts communication using [BME](https://github.com/pxcs/BlackMarlinExec/) to get access between the user and the Key Distribution Center (KDC) or between services and the LDAP directory, potentially `stealing` or `modifying` data.

> [!IMPORTANT]
> [<img src="https://darkcitygame.com/images/thumb/c/c3/Kerberos.png/500px-Kerberos.png" width="30">]()
CS might steal user credentials through phishing, allowing them to get a Ticket Granting Ticket (TGT) and access network services. Another risk is ticket forgery, where an attacker creates fake tickets to impersonate users.<br><br>

> [!WARNING]
> [<img src="https://darkcitygame.com/images/thumb/c/c3/Kerberos.png/500px-Kerberos.png" width="30">]()
Attackers intercept communications between users and the Key Distribution Center (KDC) or between services and the LDAP directory to steal or alter data. LDAP injection is another potential attack, where CS manipulate directory queries to access or change data `illegally.`<br>

## What is the Flaws in Kerberos?
Biggest lose was the assumption of secure time system, and resolution of synchronization required.

<a href="https://github.com/pxcs/BlackMarlinExec/"><p align="center">
<img width="250" height="250" src="/images/keb5.png">
</p></a>

Users authenticate once with Kerberos and can `access` multiple services without re-entering credentials, thanks to the TGT. *Haha* this is the time when the CS could use this privileges for testing.
<br>

## [LDAP](https://www.youtube.com/watch?v=S2mQBXcW3P0&pp=ygUMTERBUCBhdHRhY2tz) Automatic Injections

Using ***BME*** to automate the process of detecting and exploiting LDAP injection vulnerabilities in AD scenario. With [BME](https://github.com/pxcs/BlackMarlinExec/), CS researcher can quickly identify and exploit LDAP injection flaws, allowing CS to assess the security posture of the applications more effectively.

<a href="https://github.com/pxcs/BlackMarlinExec/"><p align="center">
<img width="170" height="170" src="/images/OSEE.svg">
</p></a>

## "More" Features

- Automated detection of LDAP injection vulnerabilities.
- Exploitation of LDAP injection vulnerabilities to extract sensitive information.
- Customizable payloads for fine-tuning injection attacks.

```
Replace `<target_url>` with the URL of the web application you want to scan.
```
For any questions or inquiries, feel free to contact the `developers` [@pxcs](https://github.com/pxcs/)

<hr>

- **Information Gathering:**
  ```powershell
  Find-DomainTarget (-p-) (-sV-) (-Pn-) (-Al-) (-more-)
  ```

- **Get Domain Controllers:**
  ```powershell
  Get-DomainController
  Get-DomainController -Domain <DomainName>
  ```
- **Enumerate Domain Users:**

  ```powershell
  Get-DomainUser | Out-File -FilePath .\DomainUsers.txt

- **Enumerate Shares:**

  ```powershell
  Find-DomainShare

  Find-DomainShare -CheckShareAccess

  Find-InterestingDomainShareFile -Include *passwords*
  ```

- **Enum Group Policies:**

  ```powershell
  Get-DomainGPO -Properties DisplayName | Sort-Object -Property DisplayName

  #Enumerate specific computer
  Get-DomainGPO -ComputerIdentity <ComputerName> -Properties DisplayName | Sort-Object -Property DisplayName

  #Get users that are local Admin group
  Get-DomainGPOComputerLocalGroupMapping -ComputerName <ComputerName>
  ```
  
- **Results Filtering:**
  ```powershell
  #grep #invert #etc
  0.0.0.0 | grep ''

  #grep with attackers .txt
  0.0.0.0 | grep 5 (-c-)(-Pn-) 'List.txt'
  ```
<hr>

## Main Usage

```
usage: BME [-h] [--command COMMAND] [--output OUTPUT] [--interface INTERFACE] [--port PORT]

options:
  -h, --help            show this help message and exit
  --command COMMAND, -c COMMAND
                        command to run on the target (default: calc)
  --output OUTPUT, -o OUTPUT
                        output maldoc file (default: BME)
  --interface INTERFACE, -i INTERFACE
                        network interface or IP address to host the HTTP server (default: eth0)
  --port PORT, -p PORT  port to serve the HTTP server (default: 8000)
```

## Intercept all responses

Now, that you know how to start DNSChef let's configure it to fake all replies to point to 127.0.0.1 using the *--fakeip* parameter:

    # ./BME --fakeip 127.0.0.1 -q
    [*] BME started on interface: 127.0.0.1 
    [*] Using the following nameservers: 8.8.8.8
    [*] Cooking all A replies to point to 127.0.0.1
    [23:55:57] 127.0.0.1: cooking the response of type 'A' for google.com to 127.0.0.1
    [23:55:57] 127.0.0.1: proxying the response of type 'AAAA' for google.com
    [23:55:57] 127.0.0.1: proxying the response of type 'MX' for google.com

In the above output you an see that BME was configured to proxy all requests to 127.0.0.1. The first line of log at 08:11:23 shows that we have "cooked" the "A" record response to point to 127.0.0.1. However, further requests for 'AAAA' and 'MX' records are simply proxied from a real DNS server. Let's see the output from requesting program:

    $ host google.com localhost
    google.com has address 127.0.0.1
    google.com has IPv6 address 2001:4860:4001:803::1001
    google.com mail is handled by 10 aspmx.l.google.com.
    google.com mail is handled by 40 alt3.aspmx.l.google.com.
    google.com mail is handled by 30 alt2.aspmx.l.google.com.

As you can see the program was tricked to use 127.0.0.1 for the IPv4 address. However, the information obtained from IPv6 (AAAA) and mail (MX) records appears completely legitimate. The goal of DNSChef is to have the least impact on the correct operation of the program, so if an application relies on a specific mailserver it will correctly obtain one through this proxied request.

Let's fake one more request to illustrate how to target multiple records at the same time:

    # ./BME --fakeip 127.0.0.1 --fakeipv6 ::1 -q
    [*] BME started on interface: 127.0.0.1 
    [*] Using the following nameservers: 8.8.8.8
    [*] Cooking all A replies to point to 127.0.0.1
    [*] Cooking all AAAA replies to point to ::1
    [00:02:14] 127.0.0.1: cooking the response of type 'A' for google.com to 127.0.0.1
    [00:02:14] 127.0.0.1: cooking the response of type 'AAAA' for google.com to ::1
    [00:02:14] 127.0.0.1: proxying the response of type 'MX' for google.com

In addition to the --fakeip flag, I have now specified --fakeipv6 designed to fake 'AAAA' record queries. Here is an updated program output:

    $ host google.com localhost
    google.com has address 127.0.0.1
    google.com has IPv6 address ::1
    google.com mail is handled by 10 aspmx.l.google.com.
    google.com mail is handled by 40 alt3.aspmx.l.google.com.
    google.com mail is handled by 30 alt2.aspmx.l.google.com.

Once more all of the records not explicitly overriden by the application were proxied and returned from the real DNS server. However, IPv4 (A) and IPv6 (AAAA) were both faked to point to a local machine.

DNSChef supports multiple record types:

Record |  Description | Argument | Example
---|---|---|---
A     | IPv4 address |--fakeip   | --fakeip 127.0.0.1
AAAA  | IPv6 address |--fakeipv6 | --fakeipv6 2001:db8::1
MX    | Mail server  |--fakemail | --fakemail mail.fake.com
CNAME | CNAME record |--fakealias| --fakealias www.fake.com
NS    | Name server  |--fakens   | --fakens ns.fake.com

## Examples

Pop results `BME.exe` :

```
$ BME.exe   
[+] copied staging doc ./
[+] finalizing payload doc ./
[x] created maldoc ./
[x] serving payload on :8000 (Example)
```
- [x] Output
- [x] Compromising Kerberos
- [x] Kerberos `Compromised!`

#### [Vulnerability Report](https://github.com/pxcs/CVE-29343-Sysmon-list/)

<a href="https://github.com/pxcs/BlackMarlin/">
    <img align="center"style="padding-right:10px;" src="https://github.com/pxcs/BlackMarlin/assets/151133481/ef88a928-41a1-4a24-810a-b70031d5efe3" /></a>
<br><br>

<a href="https://github.com/pxcs/BlackMarlinExec/"><img src="https://github.com/pxcs/BlackMarlinExec/assets/151133481/ba7ffa1c-fd3a-4dfa-8e79-0a9c1a644b19" align="right" width="70" alt="smilodon-logo"></a>
> [<img src="https://github.com/pxcs/BlackMarlinExec/assets/151133481/ba7ffa1c-fd3a-4dfa-8e79-0a9c1a644b19" width="20">]() BlackMarlinExec | Submarine project-75: <br>
***BlackMarlinExec*** is a cutting edge CS tool. Designed for comprehensive network traffic analysis and sophisticated enumeration, akin to the functionalities provided by harpoonhound. Developed for CS and penetration testers, BlackMarlinExec offers a robust suite of features tailored to identify, assess, and scan security vulnerabilities within complex network environments.<br><br>

## Network traffic analysis

#### Network Traffic Classification
This is a research project for classifying network traffic. We collected more than ***300000*** flows from some network. After that, we used nDPI to analyze the flows. We got more than 100 types of applications. Then we group that application into 10 classes. After that, we tried different ML algorithms to classify them.

#### Our current results

- Decision Tree `95.8%` accuracy
- Random Forest `96.69%` accuracy
- Regression `92.1%` accuracy
- Boosting `95.8%` accuracy
- Neural Net `97.5%` accuracy
- KNN `97.24%` accuracy
- PAA `99.29%` accuracy
- SVM `94.7%` accuracy

To get the dataset check out the instructions in the dataset folder.

#### How did we collect Data

***CS*** can use used [Wireshark](https://www.wireshark.org/) or [BlackMarlinExec](https://github.com/pxcs/BlackMarlinExec/) to collect the packets. Since for the project we wanted to use lab environment data, we first redirected the lab network to one personal computer(pc) and in that pc we used Wireshark. After collecting the packets, we used ndpi to analyze the packets and get extract flow info and then we export that data as an note file. The `data.csv` contains information on all parameters. However, for this project, we only used most important parameters as features.

## Network traffic lesson.

### Data Set
The dataset used in this demo is: [Malware_Capture](https://mcfp.felk.cvut.cz/publicDatasets/IoT-23-Dataset/IndividualScenarios/CTU-IoT-Malware-Capture-34-1/bro/).<br/>
- It is part of [Aposemat_Dataset](https://www.stratosphereips.org/datasets-iot23).
- A labeled dataset with malicious IoT network traffic.
- This dataset was created as part of the Avast AIC laboratory with the funding of Avast Software. 

#### Data Classification Details
The project is implemented in several distinct steps simulating the essential data processing and analysis phases. <br/>
- Each step is represented in a corresponding notebook inside [notebooks](notebooks).
- Intermediary data files are stored inside the [data](data) path.
- Trained models are stored inside [models](models).

#### PHASE 1 - Initial Data Analysis
> Pre note:  [Data_reading](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Implemented data exploration and cleaning tasks:
1. Loading the raw dataset file into pandas DataFrame.
2. Exploring dataset summary and statistics.
3. Fixing combined columns.
4. Dropping irrelevant columns.
5. Fixing unset values and validating data types.
6. Checking the cleaned version of the dataset.
7. Storing the cleaned dataset to a csv file.

#### PHASE 2 - Data Processing
> Corresponding note: [Data_preprocessing](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Implemented data processing and transformation tasks:
1. Loading dataset file into pandas DataFrame.
2. Exploring dataset summary and statistics.
3. Analyzing the target attribute.
4. Encoding the target attribute using [LabelEncoder](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.LabelEncoder.html).
5. Handling outliers using [IQR (Inter_quartile_Range)](https://en.wikipedia.org/wiki/Interquartile_range).
6. Handling missing values:
    1. Impute missing categorical features using [KNeighborsClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html).
    2. Impute missing numerical features using [KNNImputer](https://scikit-learn.org/stable/modules/generated/sklearn.impute.KNNImputer.html).
7. Scaling numerical attributes using [MinMaxScaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MinMaxScaler.html).
8. Encoding categorical features: handling rare values and applying [One_Hot_Encoding](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.OneHotEncoder.html).
9. Checking the processed dataset and storing it to a csv file.

#### PHASE 3 - Report Analysis
> BME:  [Data_Attack_and _exploit](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Trained and analyzed classification models:
1. Naive Bayes: [ComplementNB](https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.ComplementNB.html)
2. Decision Tree: [DecisionTreeClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.tree.DecisionTreeClassifier.html)
3. Logistic Regression: [LogisticRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html)    
4. Random Forest: [RandomForestClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html)
5. Support Vector Classifier: [SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC)
6. K-Nearest Neighbors: [KNeighborsClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html)
7. XGBoost: [XGBClassifier](https://xgboost.readthedocs.io/en/stable/index.html#)

Evaluation method: 
- Cross-Validation Technique: [Cross_Validator](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.StratifiedKFold.html)
- Folds number: Anon
- Shuffled: Enabled

Results were analyzed and compared for each model.<br/>

#### PHASE 4 - Tuning and Enumeration
> Trust Kerberos Attack: [Kerberos](https://github.com/pxcs/BlackMarlinExec/tree/main/kerberos/common)

Model tuning details:
- Tuned model: Support Vector Classifier - [SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC)
- Tuning method: [GridSearch](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.GridSearchCV.html)
- Results were analyzed before/after tuning.<br>

Publicly share you guys about my red teaming ***experiments*** tested on several environments/infrastructures that involve playing with various tools and techniques used by penetration testers and redteamers.

- [x] Project in progress
- [x] Contributions needed

**Ability**
- [x] Pivoting
- [x] Domain Enumeration
- [x] Auto `grep` results
- [x] Credential Harvesting
- [x] Network Identification

<hr>

## Building

> [!WARNING]
> This library is in beta, if something breaks don't blame me ( but feel free to open an issue 🪳 or even better open a PR )

<!---
The latest stable version [is available on PyPI](https://pypi.python.org/pypi/docker/). Either add `docker` to your `requirements.txt` file or install with pip:

    pip install dockerxxx

--> 

## What works and how well?

I'm striving for 1 to 1 feature parity with the official library ( with the exception of Swarm-related functionality ). As of writing this is beta software, take a look at the tests and the examples folder for to get a clear idea of what works.

> [!NOTE]
> The existence of tests doesn't imply that they're all currently passing

| API | Implemented | Tests  |
| --- | --- | -- |
| Containers | 80% | ✅ |
| Exec | 90% | ✅ |
| Images | 80% | ✅ | 
| Networks | 100% | ✅ |
| Nodes | 0% (Not yet) | N/A |
| Plugins | 0% | ❌ |
| Secrets | 0% | ❌ |
| Services | 0% (Not yet) | N/A |
| Swarm | 0% (Not yet) | N/A |
| Volumes | 100% | ✅ |

## Usage

Connect to Docker using the default socket or the configuration in your environment:

```python
from BME import ****
client = await AsyncDocker.from_env()
```

You can run containers:

```python
>>> await client.containers.run("ubuntu:latest", "echo compromising")
```

- Requires Python 3.11+
- Supports staging files over DNS (only over `A`,`AAAA`,`TXT` for now...)
- Config file is now TOML
- Optional HTTP API (allows you to query logs and update config remotely)
- Fully async for increased performance (uses AsyncIO)
- Structured logging and a number of QOL improvements
- Is now a Python package
- Dockerized

Refer to [BUILD.md](BUILD.md) for instructions on how to build **BME** from source.

Tests:

Travis | Coverity | GitHub Actions
------ | -------- | --------------
[![BME Travis Build status](https://travis-ci.org/pxcs/BlackMarlinExec.svg?branch=master)](https://travis-ci.org/pxcs/BlackMarlinExec) | [![Coverity Scan Build Status](https://scan.coverity.com/projects/11753/badge.svg)](https://scan.coverity.com/projects/BlackMarlinExec) | [![BME GitHub Actions Build status](https://github.com/hashcat/hashcat/actions/workflows/build.yml/badge.svg)](https://github.com/pxcs/BlackMarlinExec/actions/workflows/build.yml)

## Disclaimer
***BlackMarlinExec*** is designed primarily for research, identification, and authorized testing scenarios. This tool is to provide professionals and researchers with a tool to understand and identify vulnerabilities of the security systems. It is fundamentally imperative that users ensure they have obtained explicit, mutual consent from all involved parties before applying this tool on any system, or network. *Note*: Every time I mention CS, it's a [Cyber_Security](https://www.itgovernance.co.uk/what-is-cybersecurity) professional.

#### Educational purposes only.<br>

- If you want to report a problem, open un [Issue](https://github.com/mpgn/CrackMapExec/issues) 
- If you want to contribute, open a [Pull Request](https://github.com/mpgn/CrackMapExec/pulls)
- If you want to discuss, open a [Discussion](https://github.com/mpgn/CrackMapExec/discussions)

## Acknowledgments
**( These are the people who did the hard stuff )**

This project was inspired by:
- [CredCrack](https://github.com/gojhonny/CredCrack)
- [SMBexec](https://github.com/pentestgeek/smbexec)

## Sutton_Program Organization
Check out the ORG repo for more tools like this at [SuttonProgram](https://github.com/SuttonProgram)

## Thanks to

- Allah and [pxcs](https://github.com/pxcs/) p3xsouger
- Our Offsec team [GangstaCrew](https://github.com/GangstaCrew)
- People in Offensive CyberSec
- Some credit to U.G people
- And several open [Github](https://github.com/) repo.
