import pandas as pd
import os
import matplotlib.pyplot as plt
import seaborn as sns

names = ["quarkus-999", "quarkus-999-blocking", "quarkus-loom"]

dict=pd.DataFrame()

for i in range(0,1500,200):
    folder=f"{i}sql{i}workers"
    print(folder)

    for name in names:
        try:
            df = pd.read_csv(os.path.join(os.path.split(os.path.dirname(__file__))[0],"05cpu512ram7cpuset",folder,name+".csv"))
        except :
            continue
        ldict = df.to_dict(orient="series")
        l=[i]*len(ldict["offset"])
        series = pd.Series(data=l)
        ldict["worker-pool"]=series
        ldict["sql-pool"]=series
        ldict["type"]=pd.Series(data=[name]*len(ldict["offset"]))
        ldf=pd.DataFrame(data=ldict)
        
        dict = pd.concat([dict,ldf])

colors=["#FF014A", "#4696ed", "#063763"]

sns.set_theme()
sns.set_palette(sns.color_palette(colors))
sns.set_context(context="paper")
fig, axes = plt.subplots(2, 1 , sharex=True, sharey=False)
ax2 = sns.countplot(x='worker-pool', data=dict, hue='type', ax=axes[1])
ax = sns.boxplot(y='offset', x='worker-pool', 
                 data=dict,
                 linewidth=0.1,
                 hue='type', fliersize=0.1,ax=axes[0])
sns.despine(offset=10, trim=True)
ax2.set(xlabel='concurrency level', ylabel='#requests processed in 20 minutes')
ax.set(xlabel='concurrency level')
plt.xlabel("concurrency level")

plt.show()
