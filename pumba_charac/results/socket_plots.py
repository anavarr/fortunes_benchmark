import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


ROOT="/home/arnavarr/Documents/thesis/prog/java/CUSTOM_TECHEMP/pumba_charac"
ROOT="/home/arnavarr/Documents/thesis/prog/java/CUSTOM_TECHEMP/latency_res"

def parse_file(filename):
    with open(filename) as file:
        records = []
        lines = file.readlines()
        for line in lines:
            line = line.split(" ")
            line = list(filter(lambda string : string != '', line))
            mem_line=line[6].replace("skmem:(","").replace(")","").split(",")
            line = { 
                "net_id": line[0],
                "state" : line[1], 
                "recv_q" : float(line[2]),
                "send_q" : float(line[3]),
                "local_addr":line[4],
                "peer_addr":line[5],
                "rmem_alloc": float(mem_line[0][1:]),
                "rcv_buf":float(mem_line[1][2:]),
                "wmem_alloc":float(mem_line[2][1:]),
                "snd_buf":float(mem_line[3][2:]),
                "fwd_alloc":float(mem_line[4][1:]),
                "wmem_queued":float(mem_line[5][1:]),
                "ropt_mem":float(mem_line[6][1:]),
                "back_log":float(mem_line[7][2:]),
                "sock_drop":float(mem_line[8][1:]),
            }
            records.append(line)
        df = pd.DataFrame.from_records(records)
        return df
    
def parse_files(foldername):
    df0 = pd.DataFrame()
    for i in range(0,1000):
        try:
            df = parse_file(f"{foldername}/quarkus-999_{i}.dbc")
            df['sample']=i
            df0 = pd.concat(objs=[df0,df])
        except Exception as e:
            pass
    return df0


df = parse_files(f"{ROOT}/concurreny_lvl_7000").reset_index(drop = True) 
print(df)
fig,ax = plt.subplots(2,2)
sns.histplot(data=df, x="fwd_alloc",hue="sample", multiple="stack", ax=ax[0,0])
sns.histplot(data=df, x="send_q",hue="sample", multiple="stack", ax=ax[0,1])
sns.histplot(data=df, x="sock_drop",hue="sample", multiple="stack", ax=ax[1,0], legend=False)

count=df.groupby("sample").count().plot(ax=ax[1,1], y="back_log", label="# connections per sample")
count.set_ylim(ymin=0)
    
plt.show()
    # df = parse_files(f"{ROOT}/concurreny_lvl_2000_pumba_300")