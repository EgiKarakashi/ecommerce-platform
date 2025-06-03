// Performance monitoring and analytics for microfrontends
interface PerformanceMetric {
  name: string
  value: number
  timestamp: number
  microfrontend: string
  metadata?: Record<string, any>
}

interface ErrorMetric {
  error: Error
  microfrontend: string
  timestamp: number
  userId?: string
  sessionId: string
  metadata?: Record<string, any>
}

class MicrofrontendMonitoring {
  private metrics: PerformanceMetric[] = []
  private errors: ErrorMetric[] = []
  private sessionId: string = `session-${Date.now()}-${Math.random()}`

  // Track performance metrics
  trackPerformance(name: string, value: number, microfrontend: string, metadata?: Record<string, any>) {
    const metric: PerformanceMetric = {
      name,
      value,
      timestamp: Date.now(),
      microfrontend,
      metadata
    }
    
    this.metrics.push(metric)
    this.sendToAnalytics('performance', metric)
  }

  // Track errors
  trackError(error: Error, microfrontend: string, userId?: string, metadata?: Record<string, any>) {
    const errorMetric: ErrorMetric = {
      error,
      microfrontend,
      timestamp: Date.now(),
      userId,
      sessionId: this.sessionId,
      metadata
    }
    
    this.errors.push(errorMetric)
    this.sendToAnalytics('error', errorMetric)
  }

  // Track user interactions
  trackUserAction(action: string, microfrontend: string, metadata?: Record<string, any>) {
    this.trackPerformance(`user_action:${action}`, 1, microfrontend, metadata)
  }

  // Track load times
  trackLoadTime(microfrontend: string, startTime: number, metadata?: Record<string, any>) {
    const loadTime = performance.now() - startTime
    this.trackPerformance('load_time', loadTime, microfrontend, metadata)
  }

  // Track bundle sizes
  trackBundleSize(microfrontend: string, size: number) {
    this.trackPerformance('bundle_size', size, microfrontend)
  }

  // Send metrics to analytics service
  private async sendToAnalytics(type: 'performance' | 'error', data: any) {
    try {
      // Replace with your analytics service
      if (process.env.NODE_ENV === 'production') {
        await fetch('/api/analytics', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ type, data, sessionId: this.sessionId })
        })
      } else {
        console.log(`[Analytics ${type}]`, data)
      }
    } catch (error) {
      console.error('Failed to send analytics:', error)
    }
  }

  // Get performance report
  getPerformanceReport(microfrontend?: string) {
    const filteredMetrics = microfrontend 
      ? this.metrics.filter(m => m.microfrontend === microfrontend)
      : this.metrics

    return {
      totalMetrics: filteredMetrics.length,
      averageLoadTime: this.calculateAverage(filteredMetrics, 'load_time'),
      totalErrors: this.errors.filter(e => !microfrontend || e.microfrontend === microfrontend).length,
      metrics: filteredMetrics
    }
  }

  private calculateAverage(metrics: PerformanceMetric[], metricName: string): number {
    const relevantMetrics = metrics.filter(m => m.name === metricName)
    if (relevantMetrics.length === 0) return 0
    
    const sum = relevantMetrics.reduce((acc, m) => acc + m.value, 0)
    return sum / relevantMetrics.length
  }
}

// Global monitoring instance
export const monitoring = new MicrofrontendMonitoring()

// React hook for monitoring
export const useMonitoring = (microfrontendName: string) => {
  const trackPerformance = (name: string, value: number, metadata?: Record<string, any>) => {
    monitoring.trackPerformance(name, value, microfrontendName, metadata)
  }

  const trackError = (error: Error, userId?: string, metadata?: Record<string, any>) => {
    monitoring.trackError(error, microfrontendName, userId, metadata)
  }

  const trackUserAction = (action: string, metadata?: Record<string, any>) => {
    monitoring.trackUserAction(action, microfrontendName, metadata)
  }

  const trackLoadTime = (startTime: number, metadata?: Record<string, any>) => {
    monitoring.trackLoadTime(microfrontendName, startTime, metadata)
  }

  return { trackPerformance, trackError, trackUserAction, trackLoadTime }
}

// Performance measurement utilities
export const measurePerformance = async <T>(
  fn: () => Promise<T> | T,
  name: string,
  microfrontend: string
): Promise<T> => {
  const startTime = performance.now()
  
  try {
    const result = await fn()
    const endTime = performance.now()
    monitoring.trackPerformance(name, endTime - startTime, microfrontend)
    return result
  } catch (error) {
    monitoring.trackError(error as Error, microfrontend)
    throw error
  }
}