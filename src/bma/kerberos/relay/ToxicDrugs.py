import csv
from sets import Set

allDrugs = ['bicalutamide', 'dexamethasone', 'vapreotide', 'prednisone', 'docetaxel', 'celecoxib', 'tacrolimus', 'cytarabine', 'rosiglitazone', 'hydroxyurea', 'degarelix', 'celecoxib', 'pradefovir mesylate', 'calcitriol', 'docetaxel', 'bortezomib', 'buprenorphine', 'lapatinib', 'lorazepam', 'capecitabine', 'everolimus', 'fludarabine', 'calcitriol', 'dexamethasone', 'everolimus', 'cyclosporine', 'methylprednisolone', 'cyclosporine', 'dexmedetomidine', 'topotecan', 'sildenafil', 'vorinostat', 'pioglitazone', 'sunitinib', 'prednisolone', 'gabapentin', 'lenalidomide', 'ropivacaine', 'alprazolam', 'pentoxifylline', 'clofarabine', 'didanosine', 'pentostatin', 'galantamine', 'rivastigmine', 'domperidone', 'sorafenib', 'hydroxychloroquine', 'varenicline', 'minocycline', 'indomethacin', 'gemcitabine', 'capecitabine', 'vorinostat', 'nilotinib', 'warfarin', 'tramadol', 'cabazitaxel', 'ixabepilone', 'lenalidomide', 'temsirolimus', 'dronedarone', 'paclitaxel', 'atorvastatin', 'ethanol', 'levosimendan', 'sitaxentan', 'metformin', 'sirolimus', 'sitaxentan', 'anastrozole', 'doxorubicin', 'lidocaine', 'lovastatin', 'lumiracoxib', 'dasatinib', 'sitagliptin', 'ponatinib', 'ponatinib', 'remifentanil', 'risperidone', 'aripiprazole', 'goserelin', 'desmopressin', 'felypressin', 'pravastatin', 'ramipril', 'masoprocol', 'baclofen', 'pentagastrin', 'nicotine', 'cevimeline', 'esmolol', 'carbidopa', 'indecainide', 'betaxolol', 'oseltamivir', 'caffeine', 'succinylcholine', 'dofetilide', 'pyrimethamine', 'reserpine', 'ticlopidine', 'trospium', 'adapalene', 'midodrine', 'remikiren', 'pantoprazole', 'torasemide', 'citalopram', 'bethanidine', 'oxyphenonium', 'isoetarine', 'glimepiride', 'diflorasone', 'guanadrel', 'enflurane', 'temazepam', 'methyclothiazide', 'aminosalicylic acid', 'milrinone', 'alclometasone', 'mesalazine', 'benzatropine', 'ziprasidone', 'methysergide', 'cabergoline', 'phenytoin', 'medrysone', 'diethylstilbestrol', 'clotrimazole', 'anagrelide', 'carmustine', 'dicoumarol', 'isradipine', 'betazole', 'topiramate', 'amsacrine', 'theophylline', 'liothyronine', 'disopyramide', 'pamidronate', 'clemastine', 'venlafaxine', 'conjugated estrogens', 'travoprost', 'amcinonide', 'atomoxetine', 'bleomycin', 'etomidate', 'dapiprazole', 'tranexamic acid', 'desogestrel', 'ibutilide', 'vindesine', 'chlorthalidone', 'pentobarbital', 'acetaminophen', 'dihydroergotamine', 'amitriptyline', 'floxuridine', 'fluorometholone', 'nitroprusside', 'ipratropium bromide', 'methadone', 'atenolol', 'metixene', 'cetirizine', 'diltiazem', 'protriptyline', 'trimethadione', 'minoxidil', 'megestrol acetate', 'methylergometrine', 'buclizine', 'chlorzoxazone', 'aminoglutethimide', 'mefloquine', 'clozapine', 'sucralfate', 'doxylamine', 'norepinephrine', 'mirtazapine', 'timolol', 'trihexyphenidyl', 'mexiletine', 'amlodipine', 'oxyphencyclimine', 'triamterene', 'valrubicin', 'procyclidine', 'phenylephrine', 'carbimazole', 'digoxin', 'sulpiride', 'ethopropazine', 'nimodipine', 'progesterone', 'zoledronate', 'griseofulvin', 'nisoldipine', 'eszopiclone', 'ceruletide', 'dexbrompheniramine', 'loxapine', 'carbachol', 'secobarbital', 'miglustat', 'promazine', 'spironolactone', 'methocarbamol', 'hyoscyamine', 'zolpidem', 'triprolidine', 'streptozocin', 'carboprost tromethamine', 'trifluridine', 'prochlorperazine', 'cyproheptadine', 'nitric oxide', 'bendroflumethiazide', 'allopurinol', 'trimethoprim', 'betamethasone', 'teniposide', 'epirubicin', 'chloramphenicol', 'dipivefrin', 'droperidol', 'levothyroxine', 'framycetin', 'pethidine', 'loratadine', 'prazosin', 'imipramine', 'acitretin', 'nabumetone', 'methylscopolamine bromide', 'sodium tetradecyl sulfate', 'ketorolac', 'enoxacin', 'quinine', 'tenoxicam', 'montelukast', 'fluoxetine', 'methohexital', 'duloxetine', 'chlorpromazine', 'gallamine triethiodide', 'brimonidine', 'pefloxacin', 'sotalol', 'miglitol', 'fosinopril', 'zidovudine', 'phenindione', 'flutamide', 'tolmetin', 'cimetidine', 'haloperidol', 'levallorphan', 'triflupromazine', 'dextrothyroxine', 'acetyldigitoxin', 'dextromethorphan', 'anisotropine methylbromide', 'albendazole', 'trandolapril', 'carteolol', 'metolazone', 'cinchocaine', 'cefdinir', 'guanidine', 'nortriptyline', 'amoxapine', 'fluorouracil', 'pyridostigmine', 'adinazolam', 'desoximetasone', 'azelaic acid', 'propylthiouracil', 'acetohydroxamic acid', 'hydroxyzine', 'doxapram', 'benzthiazide', 'methotrexate', 'cisatracurium besylate', 'cinnarizine', 'vinblastine', 'atropine', 'fenoprofen', 'clonidine', 'mazindol', 'l-carnitine', 'enalapril', 'nizatidine', 'diclofenac', 'cinalukast', 'fluticasone propionate', 'lisuride', 'doxazosin', 'piperazine', 'ethosuximide', 'amiloride', 'halobetasol propionate', 'labetalol', 'thiopental', 'monobenzone', 'ivermectin', 'sulindac', 'cyclothiazide', 'chloroquine', 'bisoprolol', 'amodiaquine', 'rifabutin', 'candoxatril', 'paramethadione', 'imatinib', 'triamcinolone', 'nicardipine', 'fluphenazine', 'bacitracin', 'guanabenz', 'alendronate', 'clofibrate', 'simvastatin', 'mebendazole', 'gonadorelin', 'dyclonine', 'mitotane', 'leucovorin', 'dyphylline', 'pentazocine', 'magnesium sulfate', 'estrone', 'mecamylamine', 'verapamil', 'flumethasone pivalate', 'nilutamide', 'nafarelin', 'histamine phosphate', 'epinephrine', 'pirenzepine', 'chlorpropamide', 'tamoxifen', 'losartan', 'thioridazine', 'warfarin', 'pentosan polysulfate', 'fludrocortisone', 'moexipril', 'phentolamine', 'daunorubicin', 'furosemide', 'ergotamine', 'tizanidine', 'nicergoline', 'eplerenone', 'methazolamide', 'diethylcarbamazine', 'nedocromil', 'norethindrone', 'azatadine', 'methoxamine', 'homatropine methylbromide', 'trimipramine', 'rocuronium', 'atracurium', 'pralidoxime', 'naftifine', 'meclizine', 'pentamidine', 'hydrocortisone', 'scopolamine', 'carbinoxamine', 'prilocaine', 'tranylcypromine', 'isoflurane', 'ethotoin', 'dolasetron', 'tetracycline', 'methimazole', 'mometasone', 'metyrosine', 'olopatadine', 'hydrocortamate', 'clidinium', 'etoposide', 'hydroflumethiazide', 'tirofiban', 'oxcarbazepine', 'propiomazine', 'phenelzine', 'propantheline', 'mefenamic acid', 'naproxen', 'gadopentetate dimeglumine', 'perindopril', 'tripelennamine', 'primidone', 'sulfasalazine', 'candesartan', 'tolazoline', 'gentamicin', 'fenoldopam', 'dicyclomine', 'minaprine', 'proparacaine', 'indapamide', 'tropicamide', 'biperiden', 'ribavirin', 'phenylbutazone', 'meloxicam', 'orciprenaline', 'acetazolamide', 'disulfiram', 'ethynodiol', 'enprofylline', 'menthol', 'trifluoperazine', 'brompheniramine', 'loperamide', 'clocortolone', 'tolazamide', 'dobutamine', 'oxazepam', 'donepezil', 'nalbuphine', 'flurandrenolide', 'methylphenobarbital', 'perphenazine', 'pseudoephedrine', 'levorphanol', 'aminolevulinic acid', 'prednisolone', 'diflunisal', 'vardenafil', 'ranitidine', 'alprenolol', 'ritodrine', 'benzonatate', 'dorzolamide', 'terbutaline', 'loteprednol', 'eprosartan', 'chlorothiazide', 'isosorbide dinitrate', 'bumetanide', 'dienestrol', 'oxybuprocaine', 'testolactone', 'benzylpenicilloyl polylysine', 'rimexolone', 'triazolam', 'didanosine', 'methdilazine', 'ethacrynic acid', 'ondansetron', 'tiagabine', 'quinidine', 'amantadine', 'dinoprostone', 'ketotifen', 'cyclobenzaprine', 'phenoxybenzamine', 'famotidine', 'misoprostol', 'mesoridazine', 'maprotiline', 'oxymetazoline', 'salicylic acid', 'salmeterol', 'meclofenamic acid', 'methantheline', 'hexafluronium', 'cycrimine', 'demecarium', 'acetylsalicylic acid', 'phenprocoumon', 'felbamate', 'fexofenadine', 'rizatriptan', 'norgestimate', 'methylprednisolone', 'pindolol', 'mepivacaine', 'bromfenac', 'apraclonidine', 'methyldopa', 'azelastine', 'ezetimibe', 'dipyridamole', 'ethinyl estradiol', 'lomefloxacin', 'cyclopentolate', 'physostigmine', 'isotretinoin', 'dimenhydrinate', 'dopamine', 'oxaprozin', 'methyl aminolevulinate', 'azathioprine', 'auranofin', 'hydrochlorothiazide', 'salbutamol', 'levobupivacaine', 'cromoglicic acid', 'tioconazole', 'ketoprofen', 'edrophonium', 'metyrapone', 'cinacalcet', 'clobetasol propionate', 'glyburide', 'bethanechol', 'isosorbide mononitrate', 'trichlormethiazide', 'phylloquinone', 'mycophenolic acid', 'methoxyflurane', 'probenecid', 'mercaptopurine', 'cerulenin', 'procainamide', 'fenofibrate', 'rifampicin', 'ergoloid mesylate', 'ibuprofen', 'nitrendipine', 'mimosine', 'tocainide', 'echothiophate', 'norfloxacin', 'acetophenazine', 'isoprenaline', 'glipizide', 'promethazine', 'dihydrotachysterol', 'mequitazine', 'perhexiline', 'diphenhydramine', 'etidronic acid', 'deslanoside', 'vigabatrin', 'emedastine', 'pilocarpine', 'benzocaine', 'primaquine', 'deserpidine', 'pentolinium', 'butenafine', 'ouabain', 'hesperetin', 'fluvastatin', 'rosuvastatin', 'flucytosine', 'pimozide', 'arbutamine', 'quinacrine', 'sertraline', 'levocabastine', 'papaverine', 'chlorphenamine', 'nifedipine', 'trimethaphan', 'atovaquone', 'diazoxide', 'gliclazide', 'phenacemide', 'ambenonium', 'proflavine', 'tolbutamide', 'anisindione', 'bicalutamide', 'prednicarbate', 'proguanil', 'tiludronate', 'doxacurium chloride', 'sulfinpyrazone', 'doxepin', 'diclofenamide', 'diphenylpyraline', 'flavoxate', 'desipramine', 'thiamylal', 'bupropion', 'bretylium', 'halothane', 'dinoprost tromethamine', 'chloroprocaine', 'terazosin', 'ofloxacin', 'cilostazol', 'guanethidine', 'moclobemide', 'orphenadrine', 'phenobarbital', 'cyclizine', 'idarubicin', 'podofilox', 'rescinnamine', 'propafenone', 'naloxone', 'desflurane', 'acebutolol', 'brinzolamide', 'estramustine', 'captopril', 'zopiclone', 'tubocurarine', 'nadolol', 'flumazenil', 'lomustine', 'ridogrel', 'sparfloxacin', 'dezocine', 'levobunolol', 'fomepizole', 'metipranolol', 'finasteride', 'halofantrine', 'dantrolene', 'ketamine', 'budesonide', 'aminophylline', 'quetiapine', 'mivacurium', 'levomethadyl acetate', 'l-dopa', 'sevoflurane', 'bromodiphenhydramine', 'epoprostenol', 'gemfibrozil', 'clomipramine', 'decamethonium', 'alimemazine', 'isocarboxazid', 'olsalazine', 'gliquidone', 'ergonovine', 'paliperidone', 'hydralazine', 'carbetocin', 'fenoterol', 'glisoxepide', 'pirbuterol', 'bevantolol', 'glucosamine', 'practolol', 'oxtriphylline', 'fosphenytoin', 'polythiazide', 'quinethazone', 'cefazolin', 'metocurine', 'pancuronium', 'pipecuronium', 'vecuronium', 'cilazapril', 'forasartan', 'quinidine barbiturate', 'saprisartan', 'spirapril', 'tasosartan', 'heptabarbital', 'hexobarbital', 'mestranol', 'ephedrine', 'mephentermine', 'procaterol', 'rasagiline', 'dihydroxyaluminium', 'cortisone acetate', 'glycodiazine', 'paramethasone', 'yohimbine', 'bezafibrate', 'colchicine', 'drospirenone', 'digitoxin', 'magnesium salicylate', 'salicylate-sodium', 'salsalate', 'neostigmine', 'trisalicylate-choline', 'methotrimeprazine', 'danazol', 'clenbuterol', 'bambuterol', 'tiotropium', 'pranlukast', 'theobromine', 'acenocoumarol', 'antrafenine', 'testosterone propionate', 'nitroxoline', 'alizapride', 'ajmaline', 'amrinone', 'aprindine', 'almitrine', 'allylestrenol', 'antipyrine', 'phenazopyridine', 'oxprenolol', 'liotrix', 'ketazolam', 'solifenacin', 'cinolazepam', 'nitrazepam', 'cilastatin', 'probucol', 'tiaprofenic acid', 'propericiazine', 'amyl nitrite', 'erythrityl tetranitrate', 'acepromazine', 'aceprometazine', 'alverine', 'molindone', 'phenindamine', 'pheniramine', 'pipotiazine', 'thioproperazine', 'thiothixene', 'isopropamide', 'pargyline', 'roflumilast', 'equilin', 'calcipotriol', 'flavin adenine dinucleotide', 'acetic acid', 'niflumic acid', 'estriol', 'estropipate', 'quinestrol', 'suramin', 'bifonazole', 'cyclandelate', 'debrisoquin', 'flunarizine', 'fluspirilene', 'mepenzolate', 'tetrabenazine', 'homoharringtonine', 'bepotastine', 'milnacipran', 'clevidipine', 'ospemifene', 'iloperidone', 'ezogabine', 'ingenol mebutate', 'indacaterol', 'methsuximide', 'rotigotine', 'vandetanib', 'abiraterone', 'mianserin', 'acetylcysteine', 'icatibant', 'rufinamide', 'alogliptin', 'tapentadol', 'silodosin', 'prasugrel', 'eltrombopag', 'tolvaptan', 'regadenoson', 'asenapine', 'lacosamide', 'rivaroxaban', 'avanafil', 'alvimopan', 'temsirolimus', 'saxagliptin', 'pazopanib', 'apixaban', 'bosutinib', 'dalfampridine', 'pasireotide', 'vilazodone', 'mepyramine', 'xylometazoline', 'dabigatran etexilate', 'betahistine', 'desvenlafaxine', 'dexmethylphenidate', 'fesoterodine', 'isometheptene', 'levonordefrin', 'methacholine', 'methyltestosterone', 'naphazoline', 'nilvadipine', 'norelgestromin', 'propylhexedrine', 'lornoxicam', 'ketobemidone', 'drotaverine', 'alcaftadine', 'cabazitaxel', 'carglumic acid', 'chenodeoxycholic acid', 'difluprednate', 'mafenide', 'methylnaltrexone', 'nepafenac', 'plerixafor', 'pralatrexate', 'antazoline', 'chloropyramine', 'dimetindene', 'isothipendyl', 'roxatidine acetate', 'bopindolol', 'bupranolol', 'cinitapride', 'tofisopam', 'lurasidone', 'ticagrelor', 'tafluprost', 'ivacaftor', 'azilsartan medoxomil', 'lomitapide', 'vismodegib', 'pitavastatin', 'rilpivirine', 'crizotinib', 'ruxolitinib', 'vemurafenib', 'linagliptin', 'carfilzomib', 'linaclotide', 'mirabegron', 'regorafenib', 'aclidinium', 'enzalutamide', 'fluticasone furoate', 'pomalidomide', 'trametinib', 'dabrafenib', 'afatinib', 'levomilnacipran', 'macitentan', 'chlorcyclizine']

mydrugs = []

with open('/Users/jaypearce9/Desktop/Classes/Math_410/rawDataSheet3.csv', 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    for row in spamreader:
    	#print ' '.join(row).lower()
    	#mydrugs.append(row[0].lower())
    	mydrugs.append(' '.join(row).lower())


#print mydrugs
#print len(mydrugs)

drugList = Set([])

drugs = []

count = 0
numLines = 0

with open('/Users/jaypearce9/Desktop/Classes/Math_410/2016ToxicDrugs2.txt','r') as f:
	for line in f:
		newline = line.lower()
		#print count
		count += 1
		for i in mydrugs:
			if i in newline:
				if i not in drugList: #we haven't seen this yet
					drugs.append([1,i])
					numLines += 1
					drugList.add(i)
				else: #we seen it before
					for j in drugs:
						if j[1] == i:
							j[0] = j[0]+1


print drugList
print len(drugList)
print drugs
drugs.sort()
print drugs

numbers = []

#set all drugs to non toxic
for a in allDrugs:
	numbers.append(0)

#iterate through each drug again
for a in range(0,len(allDrugs)):
	for b in drugs:
		if allDrugs[a].lower() == b[1].lower() and b[0] >= 3:
			print 'here'
			numbers[a] = 1

print numbers
print sum(numbers)