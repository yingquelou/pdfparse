## 欧拉公式
证明 $\cos\theta + i\sin\theta = e^{i\theta}$：

由$\sin{x}$和$\cos{x}$的泰勒展开:
$$\sin x = x - \frac{x^3}{3!} + \frac{x^5}{5!} - \frac{x^7}{7!} + \ldots$$
$$\cos x = 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \frac{x^6}{6!} + \ldots$$

将$i\theta$代入$x$得：
$$\sin(i\theta) = i\theta - \frac{(i\theta)^3}{3!} + \frac{(i\theta)^5}{5!} - \frac{(i\theta)^7}{7!} + \ldots$$
$$\cos(i\theta) = 1 - \frac{(i\theta)^2}{2!} + \frac{(i\theta)^4}{4!} - \frac{(i\theta)^6}{6!} + \ldots$$
即
$$\sin(i\theta) = i\left(\theta - \frac{\theta^3}{3!} + \frac{\theta^5}{5!} - \frac{\theta^7}{7!} + \ldots\right)$$
$$\cos(i\theta) = 1 - \frac{\theta^2}{2!} + \frac{\theta^4}{4!} - \frac{\theta^6}{6!} + \ldots$$

现在，我们使用幂级数展开式来表示 $e^{i\theta}$：
$$e^{i\theta} = 1 + i\theta + \frac{(i\theta)^2}{2!} + \frac{(i\theta)^3}{3!} + \frac{(i\theta)^4}{4!} + \frac{(i\theta)^5}{5!} + \ldots$$

即
$$e^{i\theta} = 1 + i\theta - \frac{\theta^2}{2!} - i\frac{\theta^3}{3!} + \frac{\theta^4}{4!} + i\frac{\theta^5}{5!} - \ldots$$

将相同次数的实部和虚部合并，我们得到：
$$e^{i\theta} = \left(1 - \frac{\theta^2}{2!} + \frac{\theta^4}{4!} - \frac{\theta^6}{6!} + \ldots\right) + i\left(\theta - \frac{\theta^3}{3!} + \frac{\theta^5}{5!} - \frac{\theta^7}{7!} + \ldots\right)$$

我们可以看到，实部和虚部分别与 $\cos\theta$ 和 $\sin\theta$ 的泰勒展开完全相同。因此，我们可以得出结论：
$$\cos\theta + i\sin\theta = e^{i\theta}$$

证毕

## 复数与双曲函数

$$
\cos\theta + i\sin\theta = e^{i\theta}\quad 1式
$$
将$-\theta$带入得:
$$
\cos(-\theta) + i\sin(-\theta) = e^{-i\theta}
$$
即
$$
\cos\theta - i\sin\theta = e^{-i\theta} \quad 2式
$$
联立1、2式得:
$$
\cos\theta=\frac{e^{i\theta}+e^{-i\theta}}{2}\quad 3式\\
\sin\theta=\frac{e^{i\theta}-e^{-i\theta}}{2i}\quad 4式\\
$$
又
$$
\cosh\theta=\frac{e^\theta+e^{-\theta}}{2}
$$
将$i\theta$带入得:
$$
\cosh{i\theta}=\frac{e^{i\theta}+e^{-i\theta}}{2}
$$
与3式联立得:
$$
\cosh{i\theta}=\cos\theta
$$
同理:
$$\because{\sinh{\theta}=\frac{e^\theta-e^{-\theta}}{2}}$$
将$i\theta$带入得:
$$\sinh{i\theta}=\frac{e^{i\theta}-e^{-i\theta}}{2}$$
与4式联立得:
$$
\sin\theta=\frac{\sinh{i\theta}}{i}
$$
即
$$
\sin\theta=-i\sinh{i\theta}
$$
综上,可得双曲函数与三角(圆)函数的基本转换公式:
$$
\sin\theta=-i\sinh{i\theta}\\
\cos\theta=\cosh{i\theta}\\
$$
则有推论:
$$
\tan\theta=-i\tanh{i\theta}\\
\sinh\theta=-i\sin(i\theta)\\
\cosh\theta=\cos(i\theta)\\
\cosh^2\theta-\sinh^2\theta=1\\
\tanh\theta=-i\tan{i\theta}\\
\coth\theta=i\cot{i\theta}\\
\ldots
$$
## 复数与圆函数
$$
\cos(a+bi)=\cos{a}\cosh{b}-i\sin{a}\sinh{b}
$$

## 草稿
