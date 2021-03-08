import React from 'react'
import { useAragonApi } from '@aragon/api-react'
import {
  Box,
  Button,
  GU,
  Header,
  IconMinus,
  IconPlus,
  Main,
  SyncIndicator,
  Text,
  textStyle,
} from '@aragon/ui'

function App() {
    const { api, appState } = useAragonApi();
    const { tasks, isSyncing } = appState;
    const step = 2;

    console.log(appState);
    //console.log(tasks);

    return (
        <Main>
        {isSyncing && <SyncIndicator />}
        <Header
            primary="1er"
            secondary={
            <Text
                css={`
                ${textStyle('title2')}
                `}
            >
                {1}
            </Text>
            }
        />
        <Box
            css={`
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            height: ${50 * GU}px;
            ${textStyle('title3')};
            `}
        >
            1: {1}
        </Box>
        <Box>
            <div>
            <Button
                label="Add Task"
                onClick={() => api.addTask('tarea 1', 129292, 0).toPromise()}
            />
            <Button
                label="Update Task"
                onClick={() => api.updTask(0, 'tarea 1 actualizada', 192929, 1).toPromise()}
                css={`
                margin-left: ${2 * GU}px;
                `}
            />
            <Button
                label="Deleted Task"
                onClick={() => api.delTask(0).toPromise()}
                css={`
                margin-left: ${2 * GU}px;
                `}
            />
            </div>
        </Box>
        </Main>
    )
}

export default App