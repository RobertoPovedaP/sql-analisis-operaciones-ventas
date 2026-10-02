# 🛒 Análisis de Operaciones y Ventas (Advanced SQL)

![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge&logo=postgresql&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data%20Analysis-Business%20Intelligence-success?style=for-the-badge)

## 📌 Contexto del Negocio
Este proyecto se centra en la extracción y análisis de datos de un entorno transaccional complejo. El objetivo fue transformar la información dispersa de ventas, clientes, productos y empleados en métricas comerciales accionables para la fidelización de cuentas clave y la expansión de mercados[cite: 31].

## ⚙️ Arquitectura de Consultas (SQL)
Se desarrollaron scripts avanzados en bases de datos relacionales para integrar y procesar grandes volúmenes de información[cite: 31], utilizando:
* **Múltiples JOINs y Subconsultas:** Para la consolidación de entidades relacionadas[cite: 31].
* **Expresiones de Tabla Comunes (CTEs):** Para estructurar y optimizar la legibilidad de las consultas paso a paso[cite: 31].
* **Funciones de Ventana (Window Functions):** Uso de `RANK()`, `SUM() OVER`, y `PARTITION BY` para cálculos de totales móviles y ranking de productos[cite: 31].

## 💡 Insights y Estrategia Comercial
* **Comportamiento del Cliente:** Cálculo de métricas clave como el ticket promedio por país, porcentaje de clientes activos y evolución del gasto acumulado para evaluar el Customer Lifetime Value (CLV) y el ROI[cite: 31].
* **Optimización de Inventario:** Identificación del core revenue (Top 10 de productos) y líderes de ventas trimestrales (análisis de estacionalidad)[cite: 31]. 
* **Accionabilidad:** Generación de recomendaciones para priorizar el "Stock de Seguridad", prevenir quiebres de inventario (stockouts) e impulsar estrategias de cross-selling[cite: 31].

## 📂 Estructura de este Repositorio
- `/data`: Diccionario de datos y esquema de la base relacional.
- `/scripts`: Archivos `.sql` documentados con las consultas utilizadas para la extracción de métricas.
- `/docs`: Reportes analíticos derivados de las extracciones.