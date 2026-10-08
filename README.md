# 1813_Examen_MySQL_II

# PANEL BASICO PARA RECEPCIONISTA

# 1. CREACION DE VISTA
   Aquí se crea una vista "VW_EstadoEspacios" donde se puede visualizar: 
   - Espacios:Solo se listan espacios con  el estado = 'Disponible' (los que están en
     mantenimiento o inactivo no se pueden reservar).
     
   - Estado (Si esta libre o ocupado): Un espacio está 'Ocupado' si AHORA cae dentro del rango
     fecha_inicio, fecha_fin de una reserva Pendiente o Confirmada

   - Próxima Reserva: La próxima reserva es la fecha_inicio más cercana en el futuro entre las reservas Pendientes o Confirmadas

# 2. CREACION DE PROCEDIMIENTO
  Aqui se crea un procedimiento "sp_GenerarReporteDiario" donde se puede visualizar:
  - Devuelve UNA fila con tres columnas, calculadas para el día de hoy:
  - Total_Reservas_Hoy: reservas que empiezan hoy, sin contar las Canceladas.
  - Usuarios_Activos_Hoy: usuarios distintos que entraron hoy al edificio
    (un usuario que entra dos veces cuenta una sola vez).
  - Ingresos_Hoy: suma de pagos Aplicados con fecha de hoy.
    
 # 3 SIMULACION DE CONSULTA
   Una persona está dentro si su acceso fue Permitido y todavía no tiene
   hora de salida (fecha_hora_salida IS NULL).
   Se filtra por entradas de hoy para ignorar accesos viejos que nunca se
   cerraron. El evento evt_15min_auto_checkout_cierre cierra los abiertos
   al llegar la hora de cierre.
 
