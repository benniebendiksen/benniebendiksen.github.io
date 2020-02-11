```markdown
##Pandas use assignment: data cleaning, merging, and profiling

#####Check Python and Import search directories, Install and Import needed modules

#In[ ]:


import sys


#In[ ]:


print(sys.executable)


#In[ ]:


print(sys.path)


#In[ ]:


get_ipython().system(u'pip3 install xlrd')
get_ipython().system(u'pip3 install pandas')
get_ipython().system(u'pip3 install numpy')
get_ipython().system(u'pip3 install re')
get_ipython().system(u'pip3 install matplotlib')


#In[ ]:


get_ipython().system(u'pip3 install --upgrade pip')


#In[2]:


import pandas as pd
import numpy as np
import matplotlib
from matplotlib import pyplot as plt
import re
from pandas import ExcelWriter
from pandas import ExcelFile
from functools import reduce
import operator


####Data Preparation
#1) Load the energy data from the file `Energy Indicators.xls`, which is a list of indicators of [energy supply and renewable electricity production](Energy%20Indicators.xls) from the [United Nations](http://unstats.un.org/unsd/environment/excel_file_tables/2013/Energy%20Indicators.xls) for the year 2013, and should be put into a DataFrame with the variable name of **energy**.
# 
#Remaining column labels should be:
# 
#`['Country', 'Energy Supply', 'Energy Supply per Capita', '% Renewable']`
# 
#2) Convert `Energy Supply` to gigajoules (there are 1,000,000 gigajoules in a petajoule). For all countries which have missing data (e.g. data with "...") make sure this is reflected as `np.NaN` values.
# 
#3) Rename the following list of countries (for use in later questions):
# 
# ```"Republic of Korea": "South Korea",
# "United States of America": "United States",
# "United Kingdom of Great Britain and Northern Ireland": "United Kingdom",
# "China, Hong Kong Special Administrative Region": "Hong Kong"```
# 
#4) Remove numbers and/or parenthesis from country names that contain them, e.g. 
# 
#`'Bolivia (Plurinational State of)'` should be `'Bolivia'`, 
# 
#`'Switzerland17'` should be `'Switzerland'`.
# 
#<br>
# 
#5) Next, load the GDP data from the file `world_bank.csv`, which is a csv containing countries' GDP from 1960 to 2015 from [World Bank](http://data.worldbank.org/indicator/NY.GDP.MKTP.CD). Call this DataFrame **GDP**. 
# 
#6) Rename the following list of countries:
# 
# ```"Korea, Rep.": "South Korea", 
# "Iran, Islamic Rep.": "Iran",
# "Hong Kong SAR, China": "Hong Kong"```
# 
# <br>
# 
#7) Finally, load the [Sciamgo Journal and Country Rank data for Energy Engineering and Power Technology](http://www.scimagojr.com/countryrank.php?category=2102) from the file `scimagojr-3.xlsx`, which ranks countries based on their journal contributions in the aforementioned area. Call this DataFrame **ScimEn**.
# 
#8) Join the three datasets: GDP, Energy, and ScimEn into a new dataset (using the intersection of country names). Use only the last 10 years (2006-2015) of GDP data and only the top 15 countries by Scimagojr 'Rank' (Rank 1 through 15). 
# 
#The index of this DataFrame should be the name of the country, and the columns should be ['Rank', 'Documents', 'Citable documents', 'Citations', 'Self-citations',
#'Citations per document', 'H index', 'Energy Supply',
#'Energy Supply per Capita', '% Renewable', '2006', '2007', '2008',
#'2009', '2010', '2011', '2012', '2013', '2014', '2015'].
# 
#*This function should return a DataFrame with 20 columns and 15 entries.*

####Read-in and clean energy dataset

#In[6]:


def energy():
    energy = pd.ExcelFile('Energy Indicators.xls')

    # parsing first (index: 0) sheet
    total_rows = energy.book.sheet_by_index(0).nrows
    #print(f"total rows:{total_rows}")
    ##skiprows indexing starts at 1
    header = 17
    ## 244 instead of the 245 rows of interest (with header/skiprows exception) since indexing starts at 0
    nrows = 244 - header
    footer = total_rows - 244
    #print(f"header:{header}")
    #print(f"nrows:{nrows}")
    #print(f"footer:{footer}")
    #(-1) in order to allow for the column label row
    skipfooter = total_rows - nrows - header - 1
    #print(f"skipfooter:{skipfooter}")
    energy = energy.parse(0, skiprows = header, skipfooter = skipfooter)    
    energy = energy.iloc[:, 2:].copy()
    #header indexing starts at 0
    #print(energy.head())
    
    column_names = ['Country', 'Energy Supply', 'Energy Supply per Capita', '% Renewable']
    energy.columns = column_names
    energy = energy.replace("...",np.nan)
    energy['Energy Supply']= energy['Energy Supply']*1000000
    
    energy['Country'] = energy['Country'].map({'Republic of Korea': 'South Korea', "United States of America20": "United States", "United Kingdom of Great Britain and Northern Ireland19": "United Kingdom", "China, Hong Kong Special Administrative Region3": "Hong Kong"}).fillna(energy['Country'])
    #print('Hong Kong' in energy['Country'].unique())
    #print(energy['Country'])
    #preceeding mapper replaces following clunky code:

    #i = 0
    #for country in energy['Country']:
     #   if country == "Republic of Korea":
      #      energy['Country'][i] = "South Korea"
       # elif country == "United States of America20":
        #    energy['Country'][i] = "United States"
        #elif country == "United Kingdom of Great Britain and Northern Ireland19":
         #   energy['Country'][i] = "United Kingdom"
        #elif country == "China, Hong Kong Special Administrative Region3":
         #   energy['Country'][i] = "Hong Kong"
        #i+= 1


    energy['Country'] = energy['Country'].apply(lambda x: ''.join([e for e in x if not e.isdigit()])).fillna(energy['Country'])
    #preceeding lambda replaces following code:
    
    #i = 0
    #for country in energy['Country']:
     #   L = ''.join([c for c in country if not c.isdigit()])
    ##L = country.str.findall('(\d+)', expand=False).astype(int).tostring()
     #   energy['Country'][i] = energy['Country'][i].replace(country, L)
      #  i+=1
    
    ## replace '(' and ')' with empty string (i.e., eliminate these special chars) from country names, if present
    energy['Country'] = energy['Country'].apply(lambda x: re.sub(r"\s\(.*\)", "", x))
    #print('Bolivia' in energy['Country'].unique())
    return energy
energy()


####Read-in and clean GDP dataset

#In[7]:


def gdp():
    GDP = pd.read_csv('world_bank.csv', header = 4) 
    #GDP['Country Name'] = GDP['Country Name'].map({"Korea, Rep.": 'South Korea', "Iran, Islamic Rep.": 'Iran', "Hong Kong SAR, China": 'Hong Kong'}).fillna(GDP['Country Name'])
    countries_dict = {"Korea, Rep.": 'South Korea', "Iran, Islamic Rep.": 'Iran', "Hong Kong SAR, China": 'Hong Kong'}
    #no need for fillna call at end of method chain when using conditional lambda inside map call.
    GDP['Country Name'] = GDP['Country Name'].map(lambda x: x.replace(x, countries_dict[x] if x in countries_dict else x))
    #print('Iran' in GDP['Country Name'].unique())
    #preceeding lambda replaces the following otherwise lengthier code:
    
    #for i, row in GDP.iterrows():
     #   if row[0] == "Korea, Rep.":
      #      GDP['Country Name'][i] = 'South Korea'
        ##print (i, row)
        #if row[0] == "Iran, Islamic Rep.":
         #   GDP['Country Name'][i] = 'Iran'  
        #if row[0] == "Hong Kong SAR, China":
         #   GDP["Country Name"][i] = 'Hong Kong'

    GDP.rename(columns = {'Country Name': 'Country'}, inplace = True)
    GDP = GDP.loc[:, "Country":"Country Code"].join(GDP.loc[:,'2006':'2015'])
    GDP.drop(["Country Code"], axis = 1, inplace = True)
    
    return GDP
gdp()


####Read-in SciMen dataset then merge all datasets

#In[8]:




def scimen():
    
    ScimEn = pd.read_excel("scimagojr-3.xlsx")
    
    return ScimEn

#print(ScimEn)
#print(GDP['Country'][80:])

#df.drop(df.columns.to_series()["D":"R"], axis=1)
#join the three datasets: GDP, Energy, and ScimEn into a new dataset (using the intersection of country names). Use only the last 10 years (2006-2015) of GDP data and only the top 15 countries by Scimagojr 'Rank' (Rank 1 through 15).

#pd.merge(energy, GDP, ScimEn, how = 'inner', )
#print(df_final.size, df_final.shape, df_final.ndim)


def answer_one():
    
    energy1, GDP, ScimEn = energy(),gdp(),scimen()
    #print(ScimEn.columns, GDP.columns, energy1.columns)
    dfs = [ScimEn, energy1, GDP]
    #subsequent calls to merge (reduce) allows for joining across tables on specified key(s)
    df_final = reduce(lambda left,right: pd.merge(left,right,on='Country', how = 'inner'), dfs)
    df_final.set_index("Country", inplace = True)
    df_final = df_final[df_final['Rank'] <= 15]
    
    return df_final

answer_one()


####Question 2 
#The previous question joined three datasets then reduced this to just the top 15 entries. When you joined the datasets, but before you reduced this to the top 15 items, how many entries did you lose?
# 
#*This function should return a single number.*

#In[9]:


def answer_two():
    energy1, GDP, ScimEn = energy(),gdp(),scimen()
    
    dfs = [ScimEn, energy1, GDP]
    df_final2 = reduce(lambda left,right: pd.merge(left,right,on='Country', how = 'inner'), dfs)
    df_final3 = reduce(lambda left,right: pd.merge(left,right,on='Country', how = 'outer'), dfs)
    diff = len(df_final3.index) - len(df_final2.index)
    
    return diff

answer_two()


###Answer the following questions in the context of only the top 15 countries by Scimagojr Rank (aka the DataFrame returned by `answer_one()`)

####Question 3
#What is the average GDP over the last 10 years for each country? (exclude missing values from this calculation.)
# 
#*This function should return a Series named `avgGDP` with 15 countries and their average GDP sorted in descending order.*

#In[10]:


def answer_three():
    Top15 = answer_one()
    Top15['AvgGDP'] = Top15[list(Top15.loc[:,'2006':'2015'])].mean(axis = 1)
    Top15.sort_values('AvgGDP', ascending = False, inplace = True)
    #print(Top15['2006'].dtype)
    avgGDP = Top15['AvgGDP']
    return avgGDP
answer_three()


####Question 4
#By how much had the GDP changed over the 10 year span for the country with the 6th largest average GDP?
# 
#*This function should return a single number.*

#In[11]:


def answer_four():
    Top15 = answer_one()
    gdpDiff = Top15.loc['United Kingdom', '2015'] - Top15.loc['United Kingdom', '2006']
    return gdpDiff
answer_four()


####Question 5
#What is the mean `Energy Supply per Capita`?
# 
#*This function should return a single number.*

#In[12]:


def answer_five():
    Top15 = answer_one()
    meanEn = Top15['Energy Supply per Capita'].mean()
    return meanEn
answer_five()


####Question 6
#What country has the maximum % Renewable and what is the percentage?
# 
#*This function should return a tuple with the name of the country and the percentage.*

#In[13]:


def answer_six():
    Top15 = answer_one()
    myList = [] 
    for i, row in Top15.iterrows():
        myList.append((i, Top15.loc[i, "% Renewable"]))
    maxPercentRenewable = max(myList, key = operator.itemgetter(1))
    #print(type(maxPercentRenewable))
    return maxPercentRenewable
answer_six()


####Question 7
#Create a new column that is the ratio of Self-Citations to Total Citations. 
#What is the maximum value for this new column, and what country has the highest ratio?
# 
#*This function should return a tuple with the name of the country and the ratio.*

#In[14]:


def answer_seven():
    Top15 = answer_one()
    Top15['Ratio'] = Top15['Self-citations']/Top15['Citations']
    newList = []
    
    for i, row in Top15.iterrows():
        newList.append((i, Top15.loc[i, 'Ratio']))
        
    maxRatio = max(newList, key = operator.itemgetter(1))
    return maxRatio
answer_seven()


####Question 8
# 
#Create a column that estimates the population using Energy Supply and Energy Supply per capita. 
#What is the third most populous country according to this estimate?
# 
#*This function should return a single string value.*

#In[15]:


def answer_eight():
    Top15 = answer_one()
    Top15['PopEstimate'] = Top15['Energy Supply']/Top15['Energy Supply per Capita']
    myList = []
    for i, row in Top15.iterrows():
        myList.append((i, Top15.loc[i, "PopEstimate"]))
    sortedPops = sorted(myList, key = operator.itemgetter(1), reverse = True)
    answer = sortedPops[2][0]
    return answer
answer_eight()


####Question 9
#Create a column that estimates the number of citable documents per person. 
#What is the correlation between the number of citable documents per capita and the energy supply per capita? Use the `.corr()` method, (Pearson's correlation).
# 
#*This function should return a single number.*

#In[16]:


def answer_nine():
    Top15 = answer_one()
    Top15['PopEst'] = Top15['Energy Supply'] / Top15['Energy Supply per Capita']
    Top15['Citable docs per Capita'] = Top15['Citable documents'] / Top15['PopEst']
    corr = Top15['Citable docs per Capita'].corr(Top15['Energy Supply per Capita'])
    return corr
answer_nine()


####Question 10
#Create a new column with a 1 if the country's % Renewable value is at or above the median for all countries in the top 15, and a 0 if the country's % Renewable value is below the median.
# 
#*This function should return a series named `HighRenew` whose index is the country name sorted in ascending order of rank.*

#In[17]:


def answer_ten():
    Top15 = answer_one()
    Top151 = Top15[Top15['% Renewable'] >= Top15['% Renewable'].median()].copy()
    Top151['HighRenew'] = 1
    
    Top152 = Top15[Top15['% Renewable'] < Top15['% Renewable'].median()].copy()
    Top152['HighRenew'] = 0
    HighRenew = Top151[['HighRenew', 'Rank']].append(Top152[['HighRenew', 'Rank']])
    HighRenew.sort_values('Rank', inplace= True)
    HighRenew = HighRenew['HighRenew']
    
    #print(Top15['HighRenew'].dtype)
    return HighRenew
answer_ten()


####Question 11
#Use the following dictionary to group the Countries by Continent, then create a dateframe that displays the sample size (the number of countries in each continent bin), and the sum, mean, and std deviation for the estimated population of each country.
# 
# ```python
# ContinentDict  = {'China':'Asia', 
#                   'United States':'North America', 
#                   'Japan':'Asia', 
#                   'United Kingdom':'Europe', 
#                   'Russian Federation':'Europe', 
#                   'Canada':'North America', 
#                   'Germany':'Europe', 
#                   'India':'Asia',
#                   'France':'Europe', 
#                   'South Korea':'Asia', 
#                   'Italy':'Europe', 
#                   'Spain':'Europe', 
#                   'Iran':'Asia',
#                   'Australia':'Australia', 
#                   'Brazil':'South America'}
# ```
# 
#*This function should return a DataFrame with index named Continent `['Asia', 'Australia', 'Europe', 'North America', 'South America']` and columns `['size', 'sum', 'mean', 'std']`*

#In[18]:


def answer_eleven():
    Top15 = answer_one()
    Top15['PopEstimate'] = Top15['Energy Supply']/Top15['Energy Supply per Capita']
    ContinentDict  = {'China':'Asia', 
                  'United States':'North America', 
                  'Japan':'Asia', 
                  'United Kingdom':'Europe', 
                  'Russian Federation':'Europe', 
                  'Canada':'North America', 
                  'Germany':'Europe', 
                  'India':'Asia',
                  'France':'Europe', 
                  'South Korea':'Asia', 
                  'Italy':'Europe', 
                  'Spain':'Europe', 
                  'Iran':'Asia',
                  'Australia':'Australia', 
                  'Brazil':'South America'}
    index1, sizeColumn, sumColumn, meanColumn, stdColumn = [],[],[],[], []
    for index, sub_df in Top15.groupby(ContinentDict):
        index1.append(index)
        sizeColumn.append(len(sub_df.index))
        sumColumn.append(sum(sub_df['PopEstimate']))
        meanColumn.append(sub_df['PopEstimate'].mean())
        stdColumn.append(sub_df['PopEstimate'].std())
        #print(index, sub_df)
    
    dict1 = {'size': sizeColumn, 'sum': sumColumn, 'mean': meanColumn, 'std': stdColumn}
    df = pd.DataFrame.from_dict(dict1)
    df.index = index1
    df.index.name = 'Continent'
    df = df[['size','sum', 'mean','std']]
    #g1 = Top15.groupby(ContinentDict).count()
    return df

answer_eleven()


####Question 12
#Cut % Renewable into 5 bins. Group Top15 by the Continent, as well as these new % Renewable bins. How many countries are in each of these groups?
# 
#*This function should return a __Series__ with a MultiIndex of `Continent`, then the bins for `% Renewable`. Do not include groups with no countries.*

#In[19]:


def answer_twelve():
    Top15 = answer_one()
    Top15['Bins'] = pd.cut(Top15['% Renewable'], bins = 5)
    #Top15['Country'] = Top15.index


    
    ContinentDict  = {'China':'Asia', 
                  'United States':'North America', 
                  'Japan':'Asia', 
                  'United Kingdom':'Europe', 
                  'Russian Federation':'Europe', 
                  'Canada':'North America', 
                  'Germany':'Europe', 
                  'India':'Asia',
                  'France':'Europe', 
                  'South Korea':'Asia', 
                  'Italy':'Europe', 
                  'Spain':'Europe', 
                  'Iran':'Asia',
                  'Australia':'Australia', 
                  'Brazil':'South America'}
    mySeries = pd.Series()
    #Top15.set_index([ContinentDict,'Bins'])
    thg = Top15.groupby([ContinentDict, 'Bins']).size()
    thg.index.names = ['Continent', 'Bins']
    
    #df.groupby(['col1','col2']).size()
    
    #df.reset_index(inplace = True)
    #Top15.rename(columns = {'index': 'Country'}, inplace = True)
    
    myList = []
    #for indices, sub_df in df:
     #   mySeries = [(indices, sub_df.index)]
      #  myList.append(mySeries)
       # print(indices)
        #print("-----------")
        #print(sub_df)
    
    
    return thg
        
        

answer_twelve()
    


####Question 13
#Convert the Population Estimate series to a string with thousands separator (using commas). Do not round the results.
# 
#e.g. 317615384.61538464 -> 317,615,384.61538464
# 
#*This function should return a Series `PopEst` whose index is the country name and whose values are the population estimate string.*

#In[20]:


def answer_thirteen():
    Top15 = answer_one()
    Top15['PopEst'] = Top15['Energy Supply'] / Top15['Energy Supply per Capita']
    PopEst = Top15['PopEst'].apply(lambda x: '{:,}'.format(x))
    return PopEst

answer_thirteen()


####Visualization
# 
#Plotting a 'bubble plot' scatterplot to see an example visualization.

#In[21]:


def plot_optional():
    get_ipython().magic(u'matplotlib inline')
    Top15 = answer_one()
    ax = Top15.plot(x='Rank', y='% Renewable', kind='scatter', 
                    c=['#e41a1c','#377eb8','#e41a1c','#4daf4a','#4daf4a','#377eb8','#4daf4a','#e41a1c',
                       '#4daf4a','#e41a1c','#4daf4a','#4daf4a','#e41a1c','#dede00','#ff7f00'], 
                    xticks=range(1,16), s=6*Top15['2014']/10**10, alpha=.75, figsize=[16,6]);

    for i, txt in enumerate(Top15.index):
        ax.annotate(txt, [Top15['Rank'][i], Top15['% Renewable'][i]], ha='center')
    ax.set_title('Country 2014 GDP (size) and Continent (color)')
    ax.set_xlabel("Energy Engineering Rank 2013")
    ax.set_ylabel("% Renewable Electricity Production 2013")
    print("This bubble chart illustrates a distribution of a categorical and continuous variable along two dimensions of data;")
    print("country's respective continent (color of bubble) and 2014 GDP (size of bubble) across % Renewable vs. Rank dimensions.")
    
    plt.savefig('GDPAndRank.png', bbox_inches='tight')
plot_optional()


#In[ ]:

```



