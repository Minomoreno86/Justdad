# 🗺️ HOJA DE RUTA DETALLADA - CORTO PLAZO (1-2 SEMANAS)

## **Migración de Mock Data a SwiftData Real**

### **📅 CRONOGRAMA DETALLADO**

---

## **DÍA 1-2: COMPLETAR MODELOS SWIFTDATA** ✅

### ✅ **Tarea 1.1: Modelos CoreData Mejorados**

**Estado**: COMPLETADO

- ✅ Mejorado modelo `Visit` con propiedades adicionales
- ✅ Agregado modelo `VisitAttachment`
- ✅ Agregado modelo `EmergencyContact`
- ✅ Agregado modelo `AppSettings`
- ✅ Corregidos errores de compilación

### 🔄 **Tarea 1.2: Configurar DataManager**

**Estado**: EN PROGRESO
**Archivos**: `DataManager.swift`

**Acciones específicas**:

1. **Implementar container setup completo**

   ```swift
   func setupContainer() {
       let schema = Schema([
           Visit.self,
           VisitAttachment.self,
           FinancialEntry.self,
           EmotionalEntry.self,
           DiaryEntry.self,
           DiaryAttachment.self,
           CommunityPost.self,
           UserPreferences.self,
           EmergencyContact.self,
           AppSettings.self
       ])
       // ... rest of implementation
   }
   ```

2. **Agregar métodos de fetch específicos**:
   - `fetchUpcomingVisits()`
   - `fetchVisitsForDate(_:)`
   - `fetchRecentExpenses(limit:)`
   - `fetchRecentEmotionalEntries(limit:)`

**Estimación**: 4 horas

---

## **DÍA 2-3: INTEGRAR SWIFTDATA CON VISTAS EXISTENTES**

### 🔄 **Tarea 2.1: Migrar AgendaView a SwiftData**

**Estado**: PENDIENTE
**Archivos**: `AgendaView.swift`, `EditVisitView.swift`, `NewVisitView.swift`

**Acciones específicas**:

1. **Reemplazar MockVisitAgenda con Visit model**

   - Eliminar `MockVisitAgenda` struct
   - Usar `@Query` en lugar de `@State` para visits
   - Actualizar todas las referencias

2. **Implementar CRUD operations reales**:

   ```swift
   // En AgendaView
   @Query private var visits: [Visit]
   @Environment(\.modelContext) private var modelContext

   func createVisit(_ visit: AgendaVisit) {
       let newVisit = Visit(from: visit)
       modelContext.insert(newVisit)
       try? modelContext.save()
   }
   ```

3. **Actualizar filtros y búsquedas**
   - Migrar `filteredVisits` a usar `@Query` con predicados
   - Implementar búsqueda en tiempo real

**Estimación**: 6 horas

### 🔄 **Tarea 2.2: Migrar FinanceView a SwiftData**

**Estado**: PENDIENTE  
**Archivos**: `FinanceView.swift`

**Acciones específicas**:

1. **Reemplazar MockExpense con FinancialEntry**
2. **Implementar dashboard con datos reales**
3. **Agregar funcionalidad de exportación real**

**Estimación**: 4 horas

### 🔄 **Tarea 2.3: Migrar EmotionsView a SwiftData**

**Estado**: PENDIENTE
**Archivos**: `EmotionsView.swift`

**Acciones específicas**:

1. **Implementar seguimiento de humor real**
2. **Agregar gráficos con datos reales**
3. **Conectar con EmotionalEntry model**

**Estimación**: 4 horas

---

## **DÍA 3-4: IMPLEMENTAR FACE ID REAL**

### 🔄 **Tarea 3.1: Completar SecurityService**

**Estado**: PENDIENTE
**Archivos**: `SecurityService.swift`, `JustDadApp.swift`

**Acciones específicas**:

1. **Implementar autenticación biométrica funcional**:

   ```swift
   func authenticateWithBiometrics() async -> Bool {
       let context = LAContext()
       var error: NSError?

       guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
           return false
       }

       do {
           let result = try await context.evaluatePolicy(
               .deviceOwnerAuthenticationWithBiometrics,
               localizedReason: "Accede a SoloPapá de forma segura"
           )
           return result
       } catch {
           return false
       }
   }
   ```

2. **Integrar en flujo de app**:

   - Verificar en `JustDadApp.swift`
   - Mostrar pantalla de autenticación si es necesario
   - Guardar estado en AppSettings

3. **Manejar casos de error**:
   - Face ID no disponible
   - Usuario cancela
   - Fallback a contraseña

**Estimación**: 5 horas

### 🔄 **Tarea 3.2: Configurar Keychain Storage Real**

**Estado**: PENDIENTE
**Archivos**: `SecurityService.swift`

**Acciones específicas**:

1. **Implementar almacenamiento seguro de preferencias**
2. **Cifrar datos sensibles antes de guardaRTOS**
3. **Implementar cleanup seguro al desinstalar**

**Estimación**: 3 horas

---

## **DÍA 4-5: OPTIMIZAR PERFORMANCE Y TESTING**

### 🔄 **Tarea 4.1: Optimizar Queries SwiftData**

**Estado**: PENDIENTE

**Acciones específicas**:

1. **Implementar lazy loading**
2. **Optimizar predicados complejos**
3. **Agregar índices necesarios**
4. **Implementar paginación en listas largas**

**Estimación**: 4 horas

### 🔄 **Tarea 4.2: Testing Básico**

**Estado**: PENDIENTE

**Acciones específicas**:

1. **Crear datos de prueba realistas**
2. **Testear flows principales**:
   - Crear/editar/eliminar visitas
   - Autenticación biométrica
   - Navegación entre tabs
3. **Verificar performance en dispositivos más antiguos**

**Estimación**: 4 horas

---

## **DÍA 5-7: PULIR UX Y PREPARAR PARA PRODUCCIÓN**

### 🔄 **Tarea 5.1: Mejorar Estados de Carga**

**Estado**: PENDIENTE

**Acciones específicas**:

1. **Agregar loading states en todas las vistas**
2. **Implementar empty states profesionales**
3. **Manejar errores de red/storage**
4. **Agregar animaciones de transición**

**Estimación**: 4 horas

### 🔄 **Tarea 5.2: Configurar Data Migration**

**Estado**: PENDIENTE
**Archivos**: `DataManager.swift`

**Acciones específicas**:

1. **Implementar migración desde mock data**:

   ```swift
   func migrateMockDataIfNeeded() {
       let existingVisits = fetch(Visit.self)
       if existingVisits.isEmpty && shouldMigrate {
           createSampleDataFromMocks()
       }
   }
   ```

2. **Crear datos de ejemplo realistas**
3. **Verificar que la migración sea idempotente**

**Estimación**: 3 horas

---

## **📊 MÉTRICAS DE ÉXITO**

### **Funcionalidad Completa**:

- ✅ Todos los modelos SwiftData funcionando
- ✅ CRUD operations en todas las vistas principales
- ✅ Face ID/Touch ID funcional
- ✅ Navegación fluida sin errores

### **Performance**:

- ⏱️ Tiempo de carga inicial < 2 segundos
- ⏱️ Transiciones entre tabs < 500ms
- 📱 Funciona en iPhone 12 y superiores sin lag

### **UX**:

- 🎨 Estados de carga profesionales
- ⚠️ Manejo de errores usuario-friendly
- 🔄 Animaciones suaves y consistentes

---

## **🚨 RIESGOS Y MITIGACIONES**

### **Riesgo Alto**: Problemas de compilación con AgendaVisitType

- **Mitigación**: ✅ Ya resuelto - imports corregidos

### **Riesgo Medio**: Performance issues con SwiftData

- **Mitigación**: Implementar lazy loading y optimizar queries

### **Riesgo Bajo**: Face ID no disponible en simulador

- **Mitigación**: Implementar mocks para testing

---

## **📋 CHECKLIST DIARIO**

### **Antes de cada commit**:

- [ ] ✅ Código compila sin warnings
- [ ] ✅ Navegación principal funciona
- [ ] ✅ No hay memory leaks evidentes
- [ ] ✅ Estados de error manejados

### **Al final de cada día**:

- [ ] ✅ Demo de funcionalidad nueva
- [ ] ✅ Backup de trabajo
- [ ] ✅ Documentar issues encontrados

---

## **🎯 ENTREGABLES ESPECÍFICOS**

### **Día 2**:

- ✅ Modelos SwiftData completamente funcionales
- ✅ DataManager configurado y probado

### **Día 4**:

- ✅ AgendaView migrada a datos reales
- ✅ Face ID implementado y funcional

### **Día 7**:

- ✅ App completamente funcional sin mock data
- ✅ Performance optimizada
- ✅ Lista para siguientes fases

---

Esta hoja de ruta está diseñada para lograr **funcionalidad real completa** en 1-2 semanas, sin simplificar ni duplicar esfuerzos. Cada tarea tiene acciones específicas y medibles que llevan directamente a una aplicación lista para la siguiente fase de desarrollo.
