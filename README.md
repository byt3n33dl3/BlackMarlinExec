#### Black Marlin | Swordfish attacks | Enumeration tool | NTA tool

<a href="https://github.com/pxcs/BlackMarlinExec/"><p align="center">
<img width="300" height="300" src="/images/swordfish.png">
</p></a>

## About BlackMarlinExec
BlackMarlinExec uses graph and analysis theory to reveal the hidden and unintended relationships within an Active Directory or active environment. Attackers can use BlackMarlinExec to easily identify highly complex attack paths that would otherwise be impossible to `quickly` identify. It also has it's own attack path management that continuously maps and quantifies Active Directory attack paths. Attackers can see millions, even `billions` of attack paths within your existing architecture

## BlackMarlinExec Kerberos Performance
BlackMarlinExec incorporates a specialized [Kerberos](https://github.com/pxcs/KerberossianCracker) attack module, empowering security professionals to effectively test and exploit weaknesses within the Kerberos authentication protocol. This module is designed to enhance the enumeration and `analysis` capabilities by focusing on potential vulnerabilities in Kerberos implementations.

#### Ticket Harvesting by:

- AS-REP Roasting by automates the extraction of AS-REP responses for accounts that do not require pre-authentication.
- And kerberoasting to identifies and extracts service tickets (TGS) for services that leverage Kerberos.

By integrating advanced Kerberos attack techniques with [BME](https://github.com/pxcs/BlackMarlinExec/) powerful enumeration and network traffic analysis capabilities, Attackers would gain a holistic view of the network's security posture.<br>

<a href="https://github.com/pxcs/KerberossianCracker"><p align="center">
<img width="320" height="300" src="/images/cerberus.png">
</p></a>

<hr>

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

#### [Vulnerability Report](https://github.com/pxcs/CVE-29343-Sysmon-list/)

<a href="https://github.com/pxcs/BlackMarlin/">
    <img align="center"style="padding-right:10px;" src="https://github.com/pxcs/BlackMarlin/assets/151133481/ef88a928-41a1-4a24-810a-b70031d5efe3" /></a>
<br><br>

<a href="https://github.com/pxcs/BlackMarlinExec/"><img src="https://github.com/pxcs/BlackMarlinExec/assets/151133481/ba7ffa1c-fd3a-4dfa-8e79-0a9c1a644b19" align="right" width="70" alt="smilodon-logo"></a>
> [<img src="https://github.com/pxcs/BlackMarlinExec/assets/151133481/ba7ffa1c-fd3a-4dfa-8e79-0a9c1a644b19" width="20">]() BlackMarlinExec | Submarine project-75: <br>
BlackMarlinExex is a cutting edge cyber criminal tool. Designed for comprehensive network traffic analysis and sophisticated enumeration, akin to the functionalities provided by harpoonhound. Developed for cyber attacks and penetration testers, BlackMarlinExec offers a robust suite of features tailored to identify, assess, and scan security vulnerabilities within complex network environments.<br><br>

## Network traffic analysis

#### Network Traffic Classification
This is a research project for classifying network traffic. We collected more than ***300000*** flows from some network. After that, we used nDPI to analyze the flows. We got more than 100 types of applications. Then we group that application into 10 classes. After that, we tried different ML algorithms to classify them.

#### Our current results

- Decision tree `95.8%` accuracy
- Random forest `96.69%` accuracy
- KNN `97.24%` accuracy
- PAA `99.29%` accuracy

To get the dataset check out the instructions in the dataset folder.

#### How did we collect Data

~Attackers~ can use used Wireshark or [BlackMarlinExec](https://github.com/pxcs/BlackMarlinExec/) to collect the packets. Since for the project we wanted to use lab environment data, we first redirected the lab network to one personal computer(pc) and in that pc we used Wireshark. After collecting the packets, we used ndpi to analyze the packets and get extract flow info and then we export that data as an note file. The `data.csv` contains information on all parameters. However, for this project, we only used most important parameters as features.

## Network traffic lesson.

### Data Set
The dataset used in this demo is: [Malware-Capture](https://mcfp.felk.cvut.cz/publicDatasets/IoT-23-Dataset/IndividualScenarios/CTU-IoT-Malware-Capture-34-1/bro/).<br/>
- It is part of [Aposemat-Dataset](https://www.stratosphereips.org/datasets-iot23).
- A labeled dataset with malicious IoT network traffic.
- This dataset was created as part of the Avast AIC laboratory with the funding of Avast Software. 

#### Data Classification Details
The project is implemented in several distinct steps simulating the essential data processing and analysis phases. <br/>
- Each step is represented in a corresponding notebook inside [notebooks](notebooks).
- Intermediary data files are stored inside the [data](data) path.
- Trained models are stored inside [models](models).

#### PHASE 1 - Initial Data Analysis
> Pre note:  [Data-reading](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Implemented data exploration and cleaning tasks:
1. Loading the raw dataset file into pandas DataFrame.
2. Exploring dataset summary and statistics.
3. Fixing combined columns.
4. Dropping irrelevant columns.
5. Fixing unset values and validating data types.
6. Checking the cleaned version of the dataset.
7. Storing the cleaned dataset to a csv file.

#### PHASE 2 - Data Processing
> Corresponding note:  [Data-preprocessing](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Implemented data processing and transformation tasks:
1. Loading dataset file into pandas DataFrame.
2. Exploring dataset summary and statistics.
3. Analyzing the target attribute.
4. Encoding the target attribute using [LabelEncoder](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.LabelEncoder.html).
5. Handling outliers using [IQR (Inter-quartile Range)](https://en.wikipedia.org/wiki/Interquartile_range).
6. Handling missing values:
    1. Impute missing categorical features using [KNeighborsClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html).
    2. Impute missing numerical features using [KNNImputer](https://scikit-learn.org/stable/modules/generated/sklearn.impute.KNNImputer.html).
7. Scaling numerical attributes using [MinMaxScaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MinMaxScaler.html).
8. Encoding categorical features: handling rare values and applying [One-Hot Encoding](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.OneHotEncoder.html).
9. Checking the processed dataset and storing it to a csv file.

#### PHASE 3 - Report Analysis
> BME:  [Data-Attack_and _exploit](https://github.com/pxcs/BlackMarlinExec/tree/main/bma)

Trained and analyzed classification models:
1. Naive Bayes: [ComplementNB](https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.ComplementNB.html)
2. Decision Tree: [DecisionTreeClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.tree.DecisionTreeClassifier.html)
3. Logistic Regression: [LogisticRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html)    
4. Random Forest: [RandomForestClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html)
5. Support Vector Classifier: [SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC)
6. K-Nearest Neighbors: [KNeighborsClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.neighbors.KNeighborsClassifier.html)
7. XGBoost: [XGBClassifier](https://xgboost.readthedocs.io/en/stable/index.html#)

Evaluation method: 
- Cross-Validation Technique: [Cross-Validator](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.StratifiedKFold.html)
- Folds number: Anon
- Shuffled: Enabled

Results were analyzed and compared for each model.<br/>

#### PHASE 4 - Tuning and Enumeration
> Kerberos and Marlin:  [Kerberos](https://github.com/pxcs/BlackMarlinExec/tree/main/kerberos/common)

Model tuning details:
- Tuned model: Support Vector Classifier - [SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC)
- Tuning method: [GridSearch](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.GridSearchCV.html)
- Results were analyzed before/after tuning.<br>

Publicly share you guys about my red teaming ***experiments*** tested on several environments/infrastructures that involve playing with various tools and techniques used by penetration testers and redteamers.

- [x] Project in progress
- [x] Contributions needed

<hr>

# Disclaimer
***BlackMarlinExec*** is designed primarily for research, educational, and authorized testing scenarios. The purpose of developing and distributing. This tool is to provide professionals and researchers with a tool to understand and identify vulnerabilities and to bolster the security of systems. It is fundamentally imperative that users ensure they have obtained explicit, mutual consent from all involved parties before applying this tool on any system, network, or digital environment.

#### Educational purposes only.<br>

## Thanks to
Some credit to ugs people, and several [Github](https://github.com/) repo.
