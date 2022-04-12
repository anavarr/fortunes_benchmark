import json
import itertools
import matplotlib

import matplotlib.pyplot as plt
import pylab
import pandas
import os
import numpy as np

names = [
    "quarkus-999",
    "quarkus-999-blocking",
    "quarkus-loom"
]

FOLDER = "310sql310workers"
SUB_FOLDER = "c10000z20m"

i=0
fig, axes = plt.subplots(nrows=1, ncols=len(names),sharex=True, sharey=True)
fig, axesDelay = plt.subplots(nrows=1, ncols=len(names),sharex=True, sharey=True)
for name in names:
    # float64(r.numRes) / r.total.Seconds()
    axes[i].set_title(name)
    axesDelay[i].set_title(name)
    df = pandas.read_csv(os.path.join(os.path.split(os.path.dirname(__file__))[0],FOLDER,SUB_FOLDER,name+".csv"))
    count = df.count()
    print(count)
    df.boxplot(column=["response-time"],ax=axes[i], showfliers=False)
    df.boxplot(column=["Response-delay"],ax=axesDelay[i], showfliers=False)
    i+=1

plt.show()