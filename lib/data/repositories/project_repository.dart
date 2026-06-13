import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/project_model.dart';
import '../../data/datasources/local_storage.dart';

class ProjectRepository {
  Future<List<ProjectModel>> getAllProjects() async {
    final projectsData = LocalStorage.getAllProjects();
    return projectsData.map((data) => ProjectModel.fromJson(data)).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  Future<ProjectModel?> getProject(String id) async {
    final data = LocalStorage.getProject(id);
    return data != null ? ProjectModel.fromJson(data) : null;
  }

  Future<void> saveProject(ProjectModel project) async {
    await LocalStorage.saveProject(project.id, project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await LocalStorage.deleteProject(id);
  }

  Future<ProjectModel> createProject(String name) async {
    final now = DateTime.now();
    final project = ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      modifiedAt: now,
      totalDuration: Duration.zero,
      layers: [],
    );
    await saveProject(project);
    return project;
  }
}