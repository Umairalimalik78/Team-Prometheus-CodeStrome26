import { useState, useRef, useEffect } from 'react'
import { Send, ArrowLeft } from 'lucide-react'

const colors = {
  primary: '#2C1810',
  primaryWarm: '#8B4513',
  background: '#F5F0EB',
  surface: '#FFFFFF',
  inputBg: '#F0EBE5',
  textPrimary: '#1A0F0A',
  textSecondary: '#6B4C3B',
  textHint: '#A08070',
  border: '#E8DDD5',
}

const aiQuestions = [
  "What habit do you want to build, and why does it matter to you?",
  "Have you tried building this habit before? What stopped you?",
  "What are your biggest distractions or obstacles?",
  "What time of day works best for this habit?",
  "On a scale of 1-10, how motivated are you right now?"
]

function ChatScreen() {
  const [messages, setMessages] = useState([
    { role: 'assistant', content: "Hi! I'm your Habitat coach. Let's build a habit that sticks. What habit would you like to work on?" }
  ])
  const [inputValue, setInputValue] = useState('')
  const [isTyping, setIsTyping] = useState(false)
  const [questionIndex, setQuestionIndex] = useState(0)
  const messagesEndRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSend = () => {
    if (!inputValue.trim()) return

    // Add user message
    const userMessage = { role: 'user', content: inputValue }
    setMessages(prev => [...prev, userMessage])
    setInputValue('')
    setIsTyping(true)

    // Simulate AI response
    setTimeout(() => {
      let aiResponse
      if (questionIndex < aiQuestions.length) {
        aiResponse = { role: 'assistant', content: aiQuestions[questionIndex] }
        setQuestionIndex(prev => prev + 1)
      } else {
        aiResponse = { role: 'assistant', content: "INTERVIEW_COMPLETE" }
      }
      
      setMessages(prev => [...prev, aiResponse])
      setIsTyping(false)
    }, 1500)
  }

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div style={{ 
      minHeight: '100vh', 
      backgroundColor: colors.background,
      display: 'flex',
      flexDirection: 'column'
    }}>
      {/* AppBar */}
      <div style={{
        padding: '16px 20px',
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
        backgroundColor: colors.background,
        borderBottom: `1px solid ${colors.border}`
      }}>
        <button 
          onClick={() => window.history.back()}
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            padding: '4px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}
        >
          <ArrowLeft size={20} color={colors.textPrimary} />
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '15px', fontWeight: '600', color: colors.textPrimary }}>
              Habit Coach
            </span>
            <div style={{ 
              width: '8px', 
              height: '8px', 
              borderRadius: '50%', 
              backgroundColor: '#2D6A4F' 
            }} />
          </div>
          <span style={{ fontSize: '12px', color: colors.textHint }}>Online</span>
        </div>
      </div>

      {/* Header */}
      <div style={{
        padding: '28px 20px 16px',
        textAlign: 'center'
      }}>
        <h1 style={{ 
          fontSize: '24px', 
          fontWeight: '700', 
          color: colors.textPrimary,
          marginBottom: '8px'
        }}>Let's build your habit.</h1>
      </div>

      {/* Messages */}
      <div style={{ 
        flex: 1, 
        overflowY: 'auto', 
        padding: '0 20px 20px'
      }}>
        {messages.map((message, index) => (
          <div
            key={index}
            style={{
              display: 'flex',
              justifyContent: message.role === 'user' ? 'flex-end' : 'flex-start',
              marginBottom: '16px'
            }}
          >
            {message.content !== 'INTERVIEW_COMPLETE' && (
              <div
                style={{
                  maxWidth: '78%',
                  padding: '12px 14px',
                  borderRadius: message.role === 'user' 
                    ? '16px 16px 4px 16px' 
                    : '16px 16px 16px 4px',
                  backgroundColor: message.role === 'user' 
                    ? colors.primary 
                    : colors.surface,
                  color: message.role === 'user' 
                    ? '#FFFFFF' 
                    : colors.textPrimary,
                  border: message.role === 'user' 
                    ? 'none' 
                    : `1px solid ${colors.border}`,
                  fontSize: '15px',
                  lineHeight: '1.5'
                }}
              >
                {message.content}
              </div>
            )}
          </div>
        ))}

        {/* Typing Indicator */}
        {isTyping && (
          <div style={{
            display: 'flex',
            justifyContent: 'flex-start',
            marginBottom: '16px'
          }}>
            <div style={{
              padding: '12px 14px',
              borderRadius: '16px 16px 16px 4px',
              backgroundColor: colors.surface,
              border: `1px solid ${colors.border}`,
              display: 'flex',
              gap: '4px'
            }}>
              <div style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: colors.primaryWarm,
                animation: 'bounce 1.4s infinite ease-in-out both'
              }} />
              <div style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: colors.primaryWarm,
                animation: 'bounce 1.4s infinite ease-in-out both 0.16s'
              }} />
              <div style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: colors.primaryWarm,
                animation: 'bounce 1.4s infinite ease-in-out both 0.32s'
              }} />
            </div>
          </div>
        )}

        {/* Interview Complete State */}
        {messages.some(m => m.content === 'INTERVIEW_COMPLETE') && (
          <div style={{
            textAlign: 'center',
            padding: '32px',
            backgroundColor: colors.surface,
            borderRadius: '16px',
            border: `1px solid ${colors.border}`,
            margin: '16px 0'
          }}>
            <p style={{ 
              fontSize: '15px', 
              fontWeight: '600', 
              color: colors.textPrimary,
              marginBottom: '12px'
            }}>✨ Generating your habit plan...</p>
            <div style={{
              width: '100%',
              height: '4px',
              backgroundColor: colors.inputBg,
              borderRadius: '2px',
              overflow: 'hidden'
            }}>
              <div style={{
                width: '100%',
                height: '100%',
                backgroundColor: colors.primary,
                animation: 'loading 1.5s infinite'
              }} />
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input Bar */}
      {!messages.some(m => m.content === 'INTERVIEW_COMPLETE') && (
        <div style={{
          padding: '10px 16px',
          backgroundColor: colors.surface,
          borderTop: `1px solid ${colors.border}`,
          display: 'flex',
          gap: '10px',
          alignItems: 'center'
        }}>
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Type your message..."
            style={{
              flex: 1,
              padding: '12px 16px',
              borderRadius: '50px',
              border: 'none',
              backgroundColor: colors.inputBg,
              fontSize: '14px',
              color: colors.textPrimary,
              outline: 'none'
            }}
          />
          <button
            onClick={handleSend}
            disabled={!inputValue.trim()}
            style={{
              width: '40px',
              height: '40px',
              borderRadius: '50%',
              border: 'none',
              backgroundColor: inputValue.trim() ? colors.primary : colors.inputBg,
              color: '#FFFFFF',
              cursor: inputValue.trim() ? 'pointer' : 'not-allowed',
              opacity: inputValue.trim() ? 1 : 0.4,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              transition: 'all 0.2s'
            }}
          >
            <Send size={18} />
          </button>
        </div>
      )}

      <style>{`
        @keyframes bounce {
          0%, 80%, 100% { transform: scale(0); }
          40% { transform: scale(1); }
        }
        @keyframes loading {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(100%); }
        }
      `}</style>
    </div>
  )
}

export default ChatScreen
