package commands

import (
	"testing"

	"github.com/github/hub/v2/github"
	"github.com/github/hub/v2/utils"
)

func TestFork(t *testing.T) {
	// Mock necessary dependencies
	localRepoMock := &github.LocalRepoMock{}
	githubMock := &github.ClientMock{}

	// Set up test cases
	testCases := []struct {
		name     string
		args     *Args
		expected string
	}{
		// Test case 1
		{
			name: "Fork within organization",
			args: &Args{
				Flag: &Flag{
					values: map[string]string{
						"--org": "myorg",
					},
				},
			},
			expected: "Forked repository within myorg organization",
		},
		// Test case 2
		{
			name: "Skip remote addition",
			args: &Args{
				Flag: &Flag{
					values: map[string]string{
						"--no-remote": "true",
					},
				},
			},
			expected: "Forked repository without adding remote",
		},
		// Test case 3
		{
			name: "Error creating fork",
			args: &Args{},
			expected: "Error creating fork: repository already exists",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// Set up mock behavior
			localRepoMock.MainProjectFunc = func() (*github.Project, error) {
				return &github.Project{
					Host: "github.com",
					Name: "myrepo",
				}, nil
			}

			githubMock.ForkRepositoryFunc = func(project *github.Project, params map[string]interface{}) (*github.Repository, error) {
				return nil, fmt.Errorf("repository already exists")
			}

			// Call the function to be tested
			forkRepository(nil, tc.args)

			// Check the expected output
			actual := utils.GetOutput()
			if actual != tc.expected {
				t.Errorf("Expected output: %s, but got: %s", tc.expected, actual)
			}
		})
	}
}
