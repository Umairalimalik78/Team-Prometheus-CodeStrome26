import { Routes, Route } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import ChatScreen from './pages/ChatScreen'

function App() {
  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/chat" element={<ChatScreen />} />
    </Routes>
  )
}

export default App
