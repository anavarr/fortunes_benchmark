from audioop import avg
import csv
from numpy import average, block, short
import pandas as pd
import os
import matplotlib.pyplot as plt
import seaborn as sns

names = ["quarkus-999", "quarkus-999-blocking", "quarkus-loom"]

names_finale = ["reactive", "blocking", "virtual_thread"]

names_finale2names={"reactive": "quarkus-999", "blocking": "quarkus-999-blocking", "virtual_thread":"quarkus-loom"}
file_ext = ".hgrm"
prefix_path="/home/arnavarr/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res/quarkus-999-SNAPSHOT_clean_RunOnVirtualThread"
dict=pd.DataFrame()

START=800
END=2200
STEP=100

series_dict = {}
series_dict[names_finale[0]] = []
series_dict[names_finale[1]] = []
series_dict[names_finale[2]] = []

troughput_dict = {}
troughput_dict[names_finale[0]] = []
troughput_dict[names_finale[1]] = []
troughput_dict[names_finale[2]] = []

err_rate_dict = {}
err_rate_dict[names_finale[0]] = []
err_rate_dict[names_finale[1]] = []
err_rate_dict[names_finale[2]] = []

concurrency_lvls = []

memory_dict = {}
memory_dict[names_finale[0]] = []
memory_dict[names_finale[1]] = []
memory_dict[names_finale[2]] = []

total_stuff = pd.DataFrame()

rss_df = pd.DataFrame()

latency_99x_df = pd.DataFrame()

def formalize_latency_maximums(df):
    df2=pd.DataFrame(columns=["concurrency_lvl", "type", "percentile", "value"])
    lines = []
    for i in range(START,END,STEP):
        for name in names_finale:
            for p in [99, 99.9, 99.99, 99.999, 100]:
                value = get_n_percentile(df, p, name, i, 0.001)
                if value > 10 :
                    value = 10
                lines.append([i, name, p, float(value)])
    df2=pd.DataFrame(lines, columns=["concurrency_lvl", "type", "percentile", "value"])
    return df2

    df2 = df2.assign(value=[], percentile=[], type=[], concurrency_lvl=[])
    return df2

def get_n_percentile(df, perc, type, conc, precision):
    first_row = []
    row_len = 0
    interval = 0.0
    if perc == 100:
        first_row = df.index[(df["type"] == type) & (df["concurrency_value"] == conc)]
        return df.iloc[first_row[len(first_row)-1]]["Value"]

    while row_len == 0:
        first_row = df.index[(df["type"] == type) & (df["concurrency_value"] == conc) 
        & (df["Percentile"] > perc-interval)&(df["Percentile"] < perc+interval)]
        interval+=precision
        row_len = len(first_row)
    if df.iloc[first_row[0]]["Percentile"] != df.iloc[first_row[len(first_row)-1]]["Percentile"] :
        # we captured 
        limit_row, previous_row = get_middle(df, first_row)
    else :
        limit_row = df.iloc[first_row[0]]
        if limit_row["Percentile"] < perc:
            limit_row = df.iloc[first_row[len(first_row)-1]]
            previous_row = df.iloc[first_row[len(first_row)-1]+1]
        else : 
            previous_row = df.iloc[first_row[0]-1]
    
    a = previous_row["Percentile"]
    c = limit_row["Percentile"]
    x= previous_row["Value"]
    z = limit_row["Value"]
    if c == a :
        return x
    return x+ ((perc - a)*(z-x)/(c-a))

def get_middle(series, indexes):
    old_value = series.iloc[indexes[0]]["Percentile"]
    for index in indexes:
        if series.iloc[index]["Percentile"] != old_value:
            return series.iloc[index], series.iloc[index-1]
    pass

def read_files():
    for i in range(START,END,STEP):
        folder=f"concurreny_lvl_{i}"
        concurrency_lvls.append(i)
        ldict={"concurrency_lvl" : []}
        shortest=10000000
        for name in names_finale:
            ldict[f"{name}_rss"] = []
            try:
                # put everything in a df
                global total_stuff
                global series_dict
                file = open(os.path.join(prefix_path, folder, f"{name}-{i}{file_ext}"))
                df=pd.read_csv(filepath_or_buffer=os.path.join(prefix_path, folder, f"{name}-{i}{file_ext}"), sep=" ")
                mydict = df.to_dict()
                mydict["type"]=pd.Series(data=[name]*len(mydict["Value"]))
                mydict["concurrency_value"]=pd.Series(data=[i]*len(mydict["Value"]))
                total_stuff = pd.concat([total_stuff,pd.DataFrame(data=mydict)])

                lines = file.readlines()
                        
                # get the max latency result (response-time)
                line=lines[len(lines)-2]
                while(line.find(" ") == 0):
                    line=line[1:]
                number = line.split(" ")[0]
                series_dict[name]
                series_dict[name].append(float(number))

                # get the rss results
                file = open(os.path.join(prefix_path, folder, f"{names_finale2names[name]}.rss"))
                lines = file.readlines()
                memories=list(map(lambda line : float(line[0:len(line)-2]), lines))
                memory_dict[name].append(average(memories))
                if len(memories) < shortest : 
                    shortest = len(memories)
                for memory in memories:
                    ldict[f"{name}_rss"].append(memory)

                # get the througput & error-rate
                file = open(os.path.join(prefix_path, folder, f"{names_finale2names[name]}{file_ext}"))
                lines = file.readlines()
                line = list(filter(lambda line: "Requests/sec" in line, lines))[0]
                throughput = float(line.split(":")[1].strip())
                troughput_dict[name].append(throughput)

                total_req = float(list(filter(lambda line: "requests" in line, lines))[0].split("requests")[0].strip())

                line = list(filter(lambda line: "Socket errors:" in line, lines))
                if len(line) == 0:
                    err_rate_dict[name].append(0)
                else :
                    err_rate = line[0]
                    err_rate_dict[name].append(100* float(err_rate.split("requestTimeouts")[1].strip())/total_req)
            except Exception as e:
                print(e)
                print(f"error with {name}-{i}{file_ext} at {i}")
                pass
        
        # for name in names_finale:
        #     if len(ldict[f"{name}_rss"]) > shortest:
        #         ldict[f"{name}_rss"] = ldict[f"{name}_rss"][0:shortest]
        # for entry in ldict[f"{names_finale[0]}_rss"]:
        #     ldict["concurrency_lvl"].append(i)
        # ldf=pd.DataFrame(data=ldict)
        # global rss_df 
        # rss_df = pd.concat([rss_df,ldf])
    print(series_dict)

def plot_latency_focus():
    global total_stuff
    total_stuff = total_stuff.reset_index()
    df_latencies  = formalize_latency_maximums(total_stuff)
    colors=["#FF014A", "#4696ed", "#063763"]

    sns.set_theme()
    sns.set_style("whitegrid")
    sns.set_palette(sns.color_palette(colors))
    fig, ax=plt.subplots(2,2)
    fig.subplots_adjust(left=0.1,
                        bottom=0.1, 
                        right=0.9, 
                        top=0.9, 
                        wspace=0.25, 
                        hspace=0.35)
    ax[0,0].tick_params(labelrotation=45)
    ax[0,1].tick_params(labelrotation=45)
    ax[1,0].tick_params(labelrotation=45)
    ax[1,1].tick_params(labelrotation=45)
    ax0 = sns.pointplot(data=df_latencies[df_latencies["percentile"] == 99],x="concurrency_lvl", y="value", hue="type", ax=ax[0,0])
    ax0.set_xlabel("Concurrency levels (reqs/s)")
    ax0.set_ylabel("latency - lower is better")
    ax1 = sns.pointplot(data=df_latencies[df_latencies["percentile"] == 99.9],x="concurrency_lvl", y="value", hue="type", ax=ax[0,1])
    ax1.set_xlabel("Concurrency levels (reqs/s)")
    ax1.set_ylabel("latency - lower is better")
    ax2 = sns.pointplot(data=df_latencies[df_latencies["percentile"] == 99.99],x="concurrency_lvl", y="value", hue="type", ax=ax[1,0])
    ax2.set_xlabel("Concurrency levels (reqs/s)")
    ax2.set_ylabel("latency - lower is better")
    ax3 = sns.pointplot(data=df_latencies[df_latencies["percentile"] == 99.999],x="concurrency_lvl", y="value", hue="type", ax=ax[1,1])
    ax3.set_xlabel("Concurrency levels (reqs/s)")
    ax3.set_ylabel("latency - lower is better")
    ax1.legend([],[], frameon=False)
    ax2.legend([],[], frameon=False)
    ax3.legend([],[], frameon=False)
    plt.show()

def plot_summary():
    fig,ax=plt.subplots(2,2, sharex=True)
    df = pd.DataFrame(list(zip(concurrency_lvls,
        series_dict[names_finale[0]], series_dict[names_finale[1]], series_dict[names_finale[2]])),
        columns=["concurrency_lvl", "reactive", "blocking", "virtual_thread"])
    
    print(df)
    # df = pd.DataFrame(list(zip(concurrency_lvls,
    #     series_dict[names_finale[0]])),
    #     columns=["concurrency_lvl", "reactive"])



    df_throughput = pd.DataFrame(list(zip(concurrency_lvls,
        troughput_dict[names_finale[0]], troughput_dict[names_finale[1]], troughput_dict[names_finale[2]])),
        columns=["concurrency_lvl", "reactive", "blocking", "virtual_thread"])
    # df_throughput = pd.DataFrame(list(zip(concurrency_lvls,
    #     troughput_dict[names_finale[0]])),
    #     columns=["concurrency_lvl", "reactive"])



    df_rss = pd.DataFrame(list(zip(concurrency_lvls,
        memory_dict[names_finale[0]], memory_dict[names_finale[1]], memory_dict[names_finale[2]])),
        columns=["concurrency_lvl", "reactive", "blocking", "virtual_thread"])
    # df_rss = pd.DataFrame(list(zip(concurrency_lvls,
    #     memory_dict[names_finale[0]])),
    #     columns=["concurrency_lvl", "reactive"])



    # df_err_rate = pd.DataFrame(list(zip(concurrency_lvls,
    #     err_rate_dict[names_finale[0]], err_rate_dict[names_finale[1]], err_rate_dict[names_finale[2]])),
    #     columns=["concurrency_lvl", "reactive", "blocking", "virtual_thread"])
    # df_err_rate = pd.DataFrame(list(zip(concurrency_lvls,
    #     err_rate_dict[names_finale[0]], err_rate_dict[names_finale[1]])),
    #     columns=["concurrency_lvl", "reactive", "blocking"])

    axe_lat = df.plot(x="concurrency_lvl", ax=ax[0,0])
    axe_lat.set_ylabel("response time (sec) - lower is better")

    axe_th = df_throughput.plot(x="concurrency_lvl", ax=ax[0,1])
    axe_th.set_ylabel("throughput (Reqs/sec) - higher is better")

    # axe_err = df_err_rate.plot(x="concurrency_lvl", ax=ax[1,0])
    # axe_err.set_ylabel("error rate (%) - lower is better")

    axe_rss = df_rss.plot(x="concurrency_lvl", ax=ax[1,1])
    axe_rss.set_ylabel("RSS (MB) - lower is better")

    pd.set_option('display.max_rows', None)
    plt.show()

read_files()
plot_summary()