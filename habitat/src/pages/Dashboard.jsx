import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Home, ListChecks, BarChart3, UserCircle, Plus, CheckCircle2, Circle } from 'lucide-react'

const colors = {
  primary: '#2C1810',
  primaryMed: '#5C3317',
  primaryWarm: '#8B4513',
  primaryLight: '#D4956A',
  background: '#F5F0EB',
  surface: '#FFFFFF',
  inputBg: '#F0EBE5',
  textPrimary: '#1A0F0A',
  textSecondary: '#6B4C3B',
  textHint: '#A08070',
  border: '#E8DDD5',
  success: '#2D6A4F',
  successLight: '#D8F0E5',
  error: '#C0392B'
}

const mockHabits = [
  { id: 1, name: 'Morning Meditation', phase: 2, streak: 5, day: 5, completed: false },
  { id: 2, name: 'Read 30 Minutes', phase: 1, streak: 12, day: 12, completed: true },
  { id: 3, name: 'Exercise Daily', phase: 3, streak: 18, day: 18, completed: false },
]

function Dashboard() {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('pending')
  const [habits, setHabits] = useState(mockHabits)

  const toggleHabit = (id) => {
    setHabits(habits.map(h => 
      h.id === id ? { ...h, completed: !h.completed } : h
    ))
  }

  const pendingHabits = habits.filter(h => !h.completed)
  const doneHabits = habits.filter(h => h.completed)

  return (
    <div style={{ 
      minHeight: '100vh', 
      backgroundColor: colors.background,
      paddingBottom: '80px'
    }}>
      {/* AppBar */}
      <div style={{
        padding: '16px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        backgroundColor: colors.background
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span style={{ 
            fontSize: '18px', 
            fontWeight: '600', 
            color: colors.textPrimary 
          }}>Home</span>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={colors.textHint} strokeWidth="2">
            <path d="m6 9 6 6 6-6"/>
          </svg>
        </div>
        <div style={{
          width: '36px',
          height: '36px',
          borderRadius: '50%',
          backgroundColor: colors.border,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: colors.textPrimary,
          fontWeight: '600',
          fontSize: '14px'
        }}>
          A
        </div>
      </div>

      {/* Main Content */}
      <div style={{ padding: '0 20px' }}>
        <h1 style={{ 
          fontSize: '24px', 
          fontWeight: '700', 
          color: colors.textPrimary,
          marginBottom: '4px'
        }}>Good morning, Ahmed.</h1>
        <p style={{ 
          fontSize: '13px', 
          color: colors.textSecondary,
          marginBottom: '20px'
        }}>You have {pendingHabits.length} active habits today.</p>

        {/* Today's Focus Card */}
        <div style={{
          backgroundColor: colors.surface,
          borderRadius: '16px',
          padding: '16px',
          boxShadow: '0 2px 8px rgba(44,24,16,0.07)',
          border: `1px solid ${colors.border}`
        }}>
          <span style={{ 
            fontSize: '12px', 
            color: colors.textHint,
            textTransform: 'uppercase',
            letterSpacing: '0.5px'
          }}>TODAY'S FOCUS</span>

          {/* Segmented Tab Bar */}
          <div style={{
            display: 'flex',
            backgroundColor: colors.inputBg,
            borderRadius: '50px',
            padding: '4px',
            marginTop: '12px',
            marginBottom: '16px'
          }}>
            <button
              onClick={() => setActiveTab('pending')}
              style={{
                flex: 1,
                padding: '8px 16px',
                borderRadius: '50px',
                border: 'none',
                backgroundColor: activeTab === 'pending' ? colors.primary : 'transparent',
                color: activeTab === 'pending' ? '#FFFFFF' : colors.textHint,
                fontSize: '14px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s'
              }}
            >
              Pending
            </button>
            <button
              onClick={() => setActiveTab('done')}
              style={{
                flex: 1,
                padding: '8px 16px',
                borderRadius: '50px',
                border: 'none',
                backgroundColor: activeTab === 'done' ? colors.primary : 'transparent',
                color: activeTab === 'done' ? '#FFFFFF' : colors.textHint,
                fontSize: '14px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s'
              }}
            >
              Done
            </button>
          </div>

          {/* Habits List */}
          <div>
            {(activeTab === 'pending' ? pendingHabits : doneHabits).map(habit => (
              <div
                key={habit.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 0',
                  borderBottom: `1px solid ${colors.border}`,
                  opacity: habit.completed ? 0.6 : 1
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <button
                    onClick={() => toggleHabit(habit.id)}
                    style={{
                      background: 'none',
                      border: 'none',
                      cursor: 'pointer',
                      padding: 0,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    {habit.completed ? (
                      <CheckCircle2 size={24} color={colors.success} />
                    ) : (
                      <Circle size={24} color={colors.textHint} />
                    )}
                  </button>
                  <div>
                    <p style={{ 
                      fontSize: '15px', 
                      fontWeight: '600', 
                      color: colors.textPrimary,
                      textDecoration: habit.completed ? 'line-through' : 'none'
                    }}>{habit.name}</p>
                    <p style={{ 
                      fontSize: '12px', 
                      color: colors.textHint 
                    }}>Day {habit.day}/25</p>
                  </div>
                </div>
                <span style={{
                  fontSize: '12px',
                  backgroundColor: colors.inputBg,
                  padding: '4px 8px',
                  borderRadius: '12px',
                  color: colors.textSecondary
                }}>Phase {habit.phase}</span>
              </div>
            ))}
            
            {(activeTab === 'pending' ? pendingHabits : doneHabits).length === 0 && (
              <div style={{ 
                textAlign: 'center', 
                padding: '32px 0',
                color: colors.textHint 
              }}>
                {activeTab === 'pending' 
                  ? 'All habits completed! 🎉' 
                  : 'No completed habits yet'}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* FAB */}
      <button
        onClick={() => navigate('/chat')}
        style={{
          position: 'fixed',
          bottom: '84px',
          right: '20px',
          width: '56px',
          height: '56px',
          borderRadius: '16px',
          backgroundColor: colors.primary,
          border: 'none',
          color: '#FFFFFF',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 4px 12px rgba(44,24,16,0.3)',
          transition: 'transform 0.2s'
        }}
        onMouseEnter={(e) => e.target.style.transform = 'scale(1.05)'}
        onMouseLeave={(e) => e.target.style.transform = 'scale(1)'}
      >
        <Plus size={24} />
      </button>

      {/* Bottom Navigation */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        height: '64px',
        backgroundColor: colors.surface,
        borderTop: `1px solid ${colors.border}`,
        display: 'flex',
        justifyContent: 'space-around',
        alignItems: 'center',
        zIndex: 1000
      }}>
        <NavButton icon={<Home size={20} />} label="Home" active />
        <NavButton icon={<ListChecks size={20} />} label="Habits" />
        <NavButton icon={<BarChart3 size={20} />} label="Progress" />
        <NavButton icon={<UserCircle size={20} />} label="Profile" />
      </div>
    </div>
  )
}

function NavButton({ icon, label, active }) {
  const color = active ? colors.primary : colors.textHint
  
  return (
    <button
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '4px',
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        padding: '8px 16px'
      }}
    >
      <div style={{ color }}>{icon}</div>
      <span style={{ 
        fontSize: '12px', 
        fontWeight: '500', 
        color 
      }}>{label}</span>
    </button>
  )
}

export default Dashboard
