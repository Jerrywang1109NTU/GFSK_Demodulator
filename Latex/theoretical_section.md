# X  GFSK差分解调的理论误码率推导（可直接写进论文的小章节）

> 本节给出一个**可工程化落地**、且便于与仿真/FPGA结果对齐的“理论 BER 近似”推导。  
> 重点是回答：**噪声加在 I/Q 上**时，差分判决量如何建模、其均值与方差如何得到、最后 BER 为什么会出现一个 Q 函数形式。

---

## X.1  信号模型与假设（IEEE写法）

考虑接收端已经完成粗同步与频偏补偿（你的论文第3章/第5章做的事情），在正确抽样时刻（或等效的判决时刻）得到复基带采样：
\[
r_k = s_k + n_k,\quad k\in \mathbb{Z}
\tag{X-1}
\]
其中  
- \(s_k\) 为理想无噪声的GFSK（更一般地说是CPFSK/CPM）符号抽样点的复包络；
- \(n_k\) 为加性复高斯白噪声（AWGN）：
\[
n_k \sim \mathcal{CN}(0,N_0),
\quad \mathbb{E}\{|n_k|^2\}=N_0,
\quad \Re(n_k),\Im(n_k)\sim \mathcal{N}(0,N_0/2)
\tag{X-2}
\]
并假设 \(n_k\) 在不同时刻独立同分布。

对于恒包络CPM类信号（GFSK属于CPFSK/CPM一类），可以把符号抽样点表示为：
\[
s_k = \sqrt{E_b}\,e^{j\theta_k}
\tag{X-3}
\]
其中 \(\theta_k\) 为随时间累积的相位（包含调制导致的相位轨迹与未知初相）。关键在于：**差分判决只依赖相邻相位差**：
\[
\Delta\theta_k \triangleq \theta_k-\theta_{k-1}
\tag{X-4}
\]

对二进制CPFSK/GFSK，在理想抽样点附近，可把每比特对相邻采样的相位开口近似为两种取值：
\[
\Delta\theta_k \approx 
\begin{cases}
+\Delta\phi, & b_k=1 \\
-\Delta\phi, & b_k=0
\end{cases}
\tag{X-5}
\]
其中 \(\Delta\phi\) 是“有效相位开口”（effective phase opening）。  
> 对**矩形频率脉冲的CPFSK**，常见近似为 \(\Delta\phi\approx \pi h\)（\(h\) 为调制指数）；  
> 对**GFSK**（高斯平滑），由于ISI/滤波/抽样偏差等，工程上应使用 **\(\Delta\phi_{\rm eff}\)**（可由仿真/测量拟合得到）。关于GFSK差分解调与工程实现的讨论可参考差分GFSK相关文献。:contentReference[oaicite:0]{index=0}

---

## X.2  差分解调判决量的构造

你在论文里使用的差分思想本质是利用相邻样点共轭相乘（或等价的相位差）：
\[
z_k \triangleq r_k\,r_{k-1}^*
\tag{X-6}
\]
理想无噪声时：
\[
s_k s_{k-1}^* = E_b\,e^{j(\theta_k-\theta_{k-1})}
=E_b e^{j\Delta\theta_k}
\tag{X-7}
\]
因此其虚部符号给出比特判决方向：
\[
\Im\{s_k s_{k-1}^*\}=E_b\sin(\Delta\theta_k)
=
\begin{cases}
+E_b\sin(\Delta\phi), & b_k=1\\
-E_b\sin(\Delta\phi), & b_k=0
\end{cases}
\tag{X-8}
\]

于是定义一个“差分判决统计量”（与你的实现完全一致的形式）：
\[
y_k \triangleq \Im\{r_k r_{k-1}^*\}
\quad
\Rightarrow
\quad
\hat b_k=
\begin{cases}
1,& y_k>0\\
0,& y_k<0
\end{cases}
\tag{X-9}
\]

---

## X.3  展开噪声项（关键步骤）

将 \(r_k=s_k+n_k\) 代入 \(z_k=r_k r_{k-1}^*\)：
\[
\begin{aligned}
z_k
&=(s_k+n_k)(s_{k-1}^*+n_{k-1}^*)\\
&=\underbrace{s_k s_{k-1}^*}_{\text{有用项}}
+\underbrace{s_k n_{k-1}^*}_{\text{噪声项1}}
+\underbrace{n_k s_{k-1}^*}_{\text{噪声项2}}
+\underbrace{n_k n_{k-1}^*}_{\text{噪声项3}}
\end{aligned}
\tag{X-10}
\]
对虚部取值：
\[
y_k=\Im\{z_k\}
=
\Im\{s_k s_{k-1}^*\}
+\Im\{s_k n_{k-1}^*\}
+\Im\{n_k s_{k-1}^*\}
+\Im\{n_k n_{k-1}^*\}
\tag{X-11}
\]

下面分别求 \(y_k\) 在给定比特下的**均值**与**方差**。

---

## X.4  条件均值（Mean）

由于噪声均值为0，且与信号独立：
\[
\mathbb{E}\{n_k\}=0
\Rightarrow
\mathbb{E}\{\Im(s_k n_{k-1}^*)\}=0,\;
\mathbb{E}\{\Im(n_k s_{k-1}^*)\}=0
\tag{X-12}
\]
同时 \(\mathbb{E}\{\Im(n_k n_{k-1}^*)\}=0\)（独立、圆对称）。

因此：
\[
\mu_{y|b}
\triangleq \mathbb{E}\{y_k|b_k\}
=
\Im\{s_k s_{k-1}^*\}
=
\pm E_b\sin(\Delta\phi)
\tag{X-13}
\]

---

## X.5  条件方差（Variance）

定义噪声引入的随机部分：
\[
\eta_k
\triangleq
\Im\{s_k n_{k-1}^*\}
+\Im\{n_k s_{k-1}^*\}
+\Im\{n_k n_{k-1}^*\}
\tag{X-14}
\]
则
\[
y_k=\mu_{y|b}+\eta_k
\quad\Rightarrow\quad
\sigma_y^2 = \mathbb{E}\{\eta_k^2\}
\tag{X-15}
\]

### X.5.1  前两项的方差：\(\Im\{s_k n_{k-1}^*\}\) 与 \(\Im\{n_k s_{k-1}^*\}\)

注意 \(s_k=\sqrt{E_b}e^{j\theta_k}\) 仅是对噪声做了相位旋转与幅度缩放：
\[
s_k n_{k-1}^* = \sqrt{E_b}\, e^{j\theta_k}\, n_{k-1}^*
\tag{X-16}
\]
复高斯噪声在旋转下分布不变，因此 \(e^{j\theta_k}n_{k-1}^*\sim\mathcal{CN}(0,N_0)\)。再乘 \(\sqrt{E_b}\) 后：
\[
s_k n_{k-1}^*\sim \mathcal{CN}(0, E_b N_0)
\tag{X-17}
\]
圆对称复高斯的虚部方差为总功率的一半，因此：
\[
\mathrm{Var}\big(\Im\{s_k n_{k-1}^*\}\big)=\frac{E_b N_0}{2}
\tag{X-18}
\]
同理：
\[
\mathrm{Var}\big(\Im\{n_k s_{k-1}^*\}\big)=\frac{E_b N_0}{2}
\tag{X-19}
\]
且这两项使用了不同时刻的独立噪声 \(n_k\) 与 \(n_{k-1}\)，可视为互不相关，因此方差相加得到：
\[
\sigma_{12}^2 = \frac{E_b N_0}{2}+\frac{E_b N_0}{2}=E_b N_0
\tag{X-20}
\]

### X.5.2  第三项的方差：\(\Im\{n_k n_{k-1}^*\}\)

由于 \(n_k\) 与 \(n_{k-1}\) 独立，且 \(\mathbb{E}\{|n_k|^2\}=N_0\)，有：
\[
\mathbb{E}\{|n_k n_{k-1}^*|^2\}
=
\mathbb{E}\{|n_k|^2\}\,\mathbb{E}\{|n_{k-1}|^2\}
=
N_0^2
\tag{X-21}
\]
该项同样呈圆对称（工程上常用近似），其虚部功率约占一半，因此：
\[
\mathrm{Var}\big(\Im\{n_k n_{k-1}^*\}\big)\approx \frac{N_0^2}{2}
\tag{X-22}
\]

### X.5.3  合并得到总方差

综合 (X-20)(X-22)：
\[
\sigma_y^2 \approx E_b N_0 + \frac{N_0^2}{2}
\tag{X-23}
\]

---

## X.6  BER 的 Q 函数形式（核心结论）

对二进制对称判决（阈值0），误判概率为：
\[
P_b = \Pr(y_k<0|b_k=1)=\Pr(y_k>0|b_k=0)
\tag{X-24}
\]

在工程分析中，常把 \(\eta_k\) 近似为高斯（多项叠加 + 工程常用近似），因此：
\[
y_k|b_k=1 \sim \mathcal{N}\big(+E_b\sin(\Delta\phi),\;\sigma_y^2\big)
\tag{X-25}
\]
于是：
\[
P_b \approx Q\!\left(\frac{E_b\sin(\Delta\phi)}{\sqrt{E_b N_0 + \frac{N_0^2}{2}}}\right)
\tag{X-26}
\]
用 \(\gamma\triangleq E_b/N_0\) 化简：令 \(N_0=E_b/\gamma\)，代入分母：
\[
\sqrt{E_b N_0 + \frac{N_0^2}{2}}
=
E_b\sqrt{\frac{1}{\gamma}+\frac{1}{2\gamma^2}}
=
\frac{E_b}{\gamma}\sqrt{\gamma+\frac12}
\tag{X-27}
\]
因此最终得到**非常好用的闭式近似**：
\[
\boxed{
P_b \approx Q\!\left(
\frac{\gamma\,\sin(\Delta\phi)}{\sqrt{\gamma+\frac12}}
\right)
}
\qquad
(\gamma=E_b/N_0)
\tag{X-28}
\]

> 这就是我之前给你的 Q-diff 近似公式。它的优点是：
> 1) 直接刻画“噪声加在IQ上”后对差分乘积虚部的影响；  
> 2) 很容易引入“等效相位开口” \(\Delta\phi_{\rm eff}\) 来拟合你实际系统（滤波/定时/多点平均导致的开口收缩）。  
> 与差分检测/非相干检测的经典讨论是一致的思路。:contentReference[oaicite:1]{index=1}

---

## X.7  你脚本里的指数模型从哪里来（以及如何写得“IEEE”）

你脚本里的形式：
\[
P_e = \frac12 \exp\{-\gamma\sin^2(\beta/2)\}
\tag{X-29}
\]
可以写成一个**Chernoff/上界型**推导（IEEE论文常见写法）：

1) 把二元假设看作“在复平面上两个点/两条轨迹”的区分问题；对恒包络相位差为 \(\pm \Delta\phi\) 的情况，等效的欧氏距离常用：
\[
d = \left| \sqrt{E_b}e^{j\Delta\phi}-\sqrt{E_b}e^{-j\Delta\phi}\right|
= 2\sqrt{E_b}\,|\sin(\Delta\phi)|
\tag{X-30}
\]
或（更常见于相位差一半的写法）用 \(\pm \Delta\phi/2\) 表示，得到 \(d=2\sqrt{E_b}\sin(\Delta\phi/2)\)。

2) 对AWGN的二元检测，成对错误概率：
\[
P_e = Q\!\left(\frac{d}{2\sigma}\right),
\quad \sigma^2 = \frac{N_0}{2}
\tag{X-31}
\]

3) 用 Chernoff 界：
\[
Q(x)\le \frac12 e^{-x^2/2}
\tag{X-32}
\]
代入 \(x=\frac{d}{2\sigma}\)，并把 \(d\) 写成 \(\sin(\Delta\phi/2)\) 的形式，可得：
\[
P_e \lesssim \frac12 \exp\left\{-\gamma\sin^2\!\left(\frac{\Delta\phi}{2}\right)\right\}
\tag{X-33}
\]

这就解释了你脚本中“\(\sin^2(\beta/2)\)”的结构：它本质是把复杂的GFSK差分判决过程，等效为“两个点之间的距离”并再用指数上界去近似，从而得到一个简洁的指数曲线。

> 注意：这类指数形式通常更适合作为“上界/经验理论曲线”，而不是严格精确BER。IEEE里写法一般会明确说明“upper bound / approximation”。  
> DBPSK 等经典差分调制的误码表达式与这种指数形式也经常并列介绍。:contentReference[oaicite:2]{index=2}

---

## X.8  如何把 \(\Delta\phi\) 与你的GFSK参数联系起来（写法建议）

- 对理想二进制CPFSK（矩形频率脉冲），每比特相位增量常用近似：  
  \[
  \Delta\phi \approx \pi h
  \tag{X-34}
  \]
- 对GFSK，由于高斯滤波引入记忆（ISI），以及你系统中的：
  - 低通滤波与定点化
  - 帧同步使用低采样率带来的定时误差
  - 多抽样判决点平均（你的 \(N_d\)）
  
  都会使得“用于判决的有效相位开口”小于理想值，因此工程上建议写：
  \[
  \Delta\phi \to \Delta\phi_{\rm eff}
  \tag{X-35}
  \]
  并用一个测量点（例如13 dB）或最小二乘拟合得到 \(\Delta\phi_{\rm eff}\)，再代入 (X-28) 得到可对齐仿真/RTL的理论曲线。GFSK差分解调与相位包裹/实现细节在相关文献中也会讨论。:contentReference[oaicite:3]{index=3}

---

## X.9  小结（可直接作为章节末段）

本文针对“噪声加在IQ而非相位”的问题，从复基带AWGN模型出发，构造差分判决量 \(y_k=\Im\{r_k r_{k-1}^*\}\)。通过展开乘积并对噪声项求均值与方差，得到判决量在给定比特下近似服从高斯分布，其均值为 \(\pm E_b\sin(\Delta\phi)\)，方差近似为 \(E_bN_0+N_0^2/2\)。因此，GFSK差分解调的误码率可近似写为
\[
P_b \approx Q\!\left(\frac{\gamma\sin(\Delta\phi_{\rm eff})}{\sqrt{\gamma+1/2}}\right),
\quad \gamma=E_b/N_0
\]
其中 \(\Delta\phi_{\rm eff}\) 用于吸收GFSK高斯滤波记忆、定时误差与多点平均等工程因素造成的等效相位开口收缩。
