import csv
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


filename = "duplication_disaggregated.csv"


df = pd.read_csv(filename)

column_width = 3.3492706944466*2 #this is the paper column width in inches
figure_height = 1.8*2
fig, ax = plt.subplots(figsize=(column_width, figure_height))

ax = df.plot(linestyle="", marker=".", markersize=1, y="#unique comments", x="#total comments", grid=True, ax=ax, logx=True, logy=True)

xlim = plt.xlim()
ylim = plt.ylim()
x_values = np.linspace(min(xlim[0], ylim[0]), max(xlim[1], ylim[1]), 100)
plt.plot(x_values, x_values, 'r--')



fig = ax.get_figure()
fig.savefig(filename[:-3] + 'pdf', bbox_inches='tight', pad_inches=0)

df2 = df.groupby(['#unique comments', '#total comments']).size().reset_index(name='Occurrences')

df2.iloc[0] = (0.1, 0.1, df2.iloc[0, -1])

fig, ax = plt.subplots(figsize=(column_width, column_width))
scatter = ax.scatter(s=df2['Occurrences'], y=df2["#unique comments"], x=df2["#total comments"], alpha=0.7, zorder=4)
ax.grid(linestyle='-')
ax.set_ylabel('#unique comments')
ax.set_xlabel('#total comments')
ax.set_xscale('log')
ax.set_yscale('log')

xlim = plt.xlim()
ylim = plt.ylim()
x_values = np.linspace(min(xlim[0], ylim[0]), max(xlim[1], ylim[1]), 100)
plt.plot(x_values, x_values, 'r--')


labels=[1,10,100]
nums=[n for n in labels]
labels = [f'{l:,}' for l in labels]
kw = dict(prop="sizes", num=nums)
legend_elements = scatter.legend_elements(**kw)
leg = ax.legend(handles=legend_elements[0], labels=labels, fontsize=8, labelspacing=0.7, loc=4, title="Project Instances", borderpad=0.8, framealpha=0.5)



fig = ax.get_figure()
fig.savefig(filename[:-4] + '2.pdf', bbox_inches='tight', pad_inches=0)