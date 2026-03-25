 SG2 Cell-Free MISO Simulation Framework

## 仿真框架说明

本仿真框架实现了论文《Enabling High-Rate and Wide-Coverage Communications for Smart Grid 2.0 via Distributed Cell-Free MIMO》中的 **Two-Timescale JDC-IPC 算法**，用于回应审稿人的全部仿真相关意见。

---

## 📁 文件结构

```
Sim_SG2/
├── main_simulation.m          # 主仿真入口（运行所有仿真）
├── two_timescale_jdc_ipc.m    # 核心算法实现
├── channel_models.m           # 信道模型（含 CSI 误差）
├── performance_metrics.m      # 性能指标计算
├── plot_functions.m           # 绘图函数
└── README.md                  # 本说明文件
```

---

## 🎯 仿真图清单

| 图号 | 内容 | 回应审稿人意见 |
|------|------|----------------|
| **Fig 1** | Network Densification vs SINR (含理论极限线) | R2-Q4: 理论验证 |
| **Fig 2** | Coverage Distance vs Achievable Rate | 覆盖 - 速率权衡 |
| **Fig 3** | CDF of Achievable Rate (5th Percentile) | R2-Q5: 可靠性指标 |
| **Fig 4** | Outage Probability vs Target Rate | R2-Q5: 中断概率 |
| **Fig 5** | Dynamic Priority Response (时间序列) | R1-Q7, R2-Q2: 信息物理融合 |
| **Fig 6** | Convergence Analysis + Sparsity Trade-off | R2-Q7, R2-Q9, R3-Q5 |
| **Fig 7** | CSI Error Robustness | R2-Q10: 非理想 CSI |

---

## 🚀 快速开始

### 运行全部仿真

```matlab
cd /path/to/SG2_Cell-free-paper/Sim_SG2
main_simulation
```

### 运行单个仿真

在 MATLAB 命令窗口中调用相应函数：

```matlab
% 首先需要加载参数（从 main_simulation 中复制）
params.CarrierFreq = 230e6;
params.BW_Wide = 1e6;
params.NoisePSD = -130;
params.P_max_dBm = 43;
params.P_max = 10^((params.P_max_dBm-30)/10);
params.Noise_WB = 10^((params.NoisePSD-30)/10) * params.BW_Wide;
params.PathLossExp = 3.5;
params.RefLoss_dB = 30;
params.Gamma_High_dB = 15;
params.Gamma_Low_dB = 5;
params.Gamma_High_lin = 10^(params.Gamma_High_dB/10);
params.Gamma_Low_lin = 10^(params.Gamma_Low_dB/10);
params.Mu_Cluster = 0.05;
params.Mu_Precod = 0;
params.ConvTol = 1e-3;
params.MaxIter_Cluster = 30;
params.MaxIter_Precod = 50;

% 运行单个仿真
run_fig1_density_vs_sinr(params)
run_fig5_dynamic_priority(params)
```

---

## 🔧 核心算法说明

### Two-Timescale JDC-IPC 算法

算法分为两个阶段：

#### Phase 1: Long-Term Statistical Clustering
- **输入**: 统计 CSI（大尺度衰落）
- **目标**: 形成稳定的 BS-UE 聚类
- **方法**: Reweighted ℓ₁-norm 最小化 + WMMSE
- **输出**: 活跃链路掩码 `active_mask`

#### Phase 2: Short-Term WMMSE Precoding
- **输入**: 瞬时 CSI + 固定聚类
- **目标**: 满足瞬时 QoS 约束
- **方法**: 标准 WMMSE（无稀疏惩罚）
- **输出**: 最终预编码矩阵 `W`

### 关键函数

```matlab
% 标准调用（自动处理两阶段）
W = two_timescale_jdc_ipc(H, params, priority_vec);

% 带 Lagrange 乘子输出（用于 Fig 5）
[W, lambda] = two_timescale_jdc_ipc_with_output(H, params, priority_vec, Gamma_Target);

% 带收敛跟踪（用于 Fig 6）
[W, conv_history] = two_timescale_jdc_ipc_convergence(H, params, priority_vec);
```

---

## 📊 参数配置

### 系统参数（Table I）

| 参数 | 值 | 说明 |
|------|-----|------|
| CarrierFreq | 230 MHz | 电力专用频段 |
| BW_Wide | 1 MHz | 宽带模式 |
| BW_NB | 25 kHz | 窄带模式 |
| NoisePSD | -130 dBm/Hz | 噪声功率谱密度 |
| P_max | 43 dBm (20W) | BS 最大功率 |
| PathLossExp | 3.5 | 路径损耗指数 |

### 算法参数

| 参数 | 值 | 说明 |
|------|-----|------|
| Gamma_High_dB | 15 dB | 高优先级 SINR 目标 |
| Gamma_Low_dB | 5 dB | 低优先级 SINR 目标 |
| Mu_Cluster | 0.05 | 聚类阶段稀疏惩罚 |
| MaxIter_Cluster | 30 | 聚类最大迭代次数 |
| MaxIter_Precod | 50 | 预编码最大迭代次数 |

---

## 🎨 输出格式

所有仿真图自动保存为：
- `FigX_*.png` (300 DPI, 用于快速预览)
- `FigX_*.pdf` (矢量图，用于论文)

---

## 🔬 仿真场景说明

### Fig 5: Dynamic Priority Response

**故障场景设置**:
- `t = 1~7`: 电网正常运行，所有用户低优先级 (5 dB)
- `t = 8~17`: 电网突发故障，用户 1 提升至高优先级 (15 dB)
- `t = 18~25`: 故障清除，恢复正常

**观察指标**:
- 用户 1 的实际 SINR 跟踪目标 SINR 的能力
- Lagrange 乘子 λ₁ 的动态变化（故障期间自动飙升）
- 用户 2 的性能影响（资源重新分配的代价）

---

## ⚠️ 注意事项

1. **运行时间**: 完整仿真约需 30-60 分钟（取决于 CPU 性能）
   - Fig 3 (CDF) 和 Fig 4 (Outage) 需要 10000 次 Monte Carlo，耗时最长
   - 可先运行 Fig 1, Fig 2, Fig 5 快速验证

2. **内存需求**: 建议至少 8GB RAM
   - 大规模 Monte Carlo 会累积大量数据

3. **MATLAB 版本**: 需要 R2018b 或更高版本
   - 使用 `yline`, `xline` 等较新函数

4. **随机种子**: 如需复现结果，在 `main_simulation` 开头添加：
   ```matlab
   rng(42)  % 固定随机种子
   ```

---

## 📈 预期结果

### Fig 1 关键观察
- Cellular 曲线应**饱和于理论极限线**（约 0-5 dB）
- Proposed 算法应在达到 QoS 目标后**降低功率**
- RZF 应持续满功率运行

### Fig 3 关键观察
- Proposed 的 5th Percentile Rate 应显著高于基线
- CDF 曲线左侧（低速率区域）Proposed 应明显左移

### Fig 5 关键观察
- t=8 时 λ₁ 应**急剧上升**（响应 QoS 目标提升）
- 用户 1 的 SINR 应**快速跟踪**新的目标
- 故障清除后 λ₁ 应**缓慢下降**（非对称更新）

---

## 🐛 故障排除

### 问题：算法不收敛
- 检查 `params.MaxIter_Precod` 是否足够（建议≥30）
- 调整 `Step_Lambda` 步长（当前 15.0 / 0.15 非对称）

### 问题：聚类全零（所有链路被剪枝）
- `params.Mu_Cluster` 过大，建议降至 0.01
- 检查 `threshold` 设置（当前为 `1e-3 * max(abs(W(:)))`）

### 问题：SINR 远低于预期
- 检查信道模型参数（`PathLossExp`, `RefLoss_dB`）
- 确认噪声功率计算正确

---

## 📧 联系

如有问题，请联系：
- Peng Gao: gaopeng8@sgepri.sgcc.com.cn

---

**最后更新**: 2026-03-25
**版本**: 1.0 (Major Revision Response)
