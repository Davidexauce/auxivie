import styles from '../styles/SimpleChart.module.css';

export default function SimpleChart({ title, data, maxValue, color = '#059669' }) {
  if (!data || data.length === 0) {
    return (
      <div className={styles.chart}>
        <h3 className={styles.chartTitle}>{title}</h3>
        <p className={styles.noData}>Aucune donnée disponible</p>
      </div>
    );
  }

  const max = maxValue || Math.max(...data.map(d => d.value));

  return (
    <div className={styles.chart}>
      <h3 className={styles.chartTitle}>{title}</h3>
      <div className={styles.chartContent}>
        {data.map((item, index) => {
          const percentage = max > 0 ? (item.value / max) * 100 : 0;
          return (
            <div key={index} className={styles.chartBar}>
              <div className={styles.barLabel}>
                <span className={styles.labelName}>{item.label}</span>
                <span className={styles.labelValue}>{item.value}</span>
              </div>
              <div className={styles.barContainer}>
                <div
                  className={styles.bar}
                  style={{
                    width: `${percentage}%`,
                    backgroundColor: item.color || color,
                  }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

