// app/src/script.js
import 'core-js/stable'
import 'regenerator-runtime/runtime'
import Aragon, { events } from '@aragon/api'

const app = new Aragon()

app.store(
  async (state, { event, returnValues }) => {
    let nextState = { ...state }
    console.log(event);
    try {
      switch (event) {
        case 'AddTask': {
            nextState.tasks = { ...state.tasks }
            nextState.tasks[returnValues.entity] = state.tasks[returnValues.entity] ? [ ...state.tasks[returnValues.entity] ] : []
            //forma compacta: { ...state, tasks: { ...state.tasks, [returnValues.entity]: [...state[returnValues.entity], await getTask(returnValues)] } }        
            nextState.tasks[returnValues.entity].push(await getTask(returnValues))
            return nextState
        }
        case 'DelTask': {
            nextState.tasks = { ...state.tasks }
            nextState.tasks[returnValues.entity] = [ ...state.tasks[returnValues.entity] ] ? [ ...state.tasks[returnValues.entity] ] : []
            nextState.tasks[returnValues.entity] = nextState.tasks[returnValues.entity].filter(({ id }) => { return id !== returnValues.taskId} )
            return nextState
        }
        case 'UpdTask': {
            nextState.tasks = { ...state.tasks }
            nextState.tasks[returnValues.entity] = [ ...state.tasks[returnValues.entity] ] ? [ ...state.tasks[returnValues.entity] ] : []
            nextState.tasks[returnValues.entity][returnValues.taskId] = await getTask(returnValues)
            return nextState
        }
        case events.SYNC_STATUS_SYNCING: {
            return { ...nextState, isSyncing: true }
        }
        case events.SYNC_STATUS_SYNCED: {
            console.log({ ...nextState, isSyncing: false })
            return { ...nextState, isSyncing: false }
        }
        default:
            return state
      }
    } catch (err) {
        console.log(err)
    }
  },
  /* {
      init: initializeState()
  } */
)

function initializeState() {
    return async cachedState => {
        console.log("cachedState")
        console.log(cachedState)
        return {
            ...cachedState,
            tasks: {}
        }
    }
  }

async function getTask(eventParams) {
    const { entity, taskId } = eventParams
    let task = await app.call('tasks', entity, taskId).toPromise()
    return task
}